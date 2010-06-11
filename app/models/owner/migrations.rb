class Owner
  
  before_update :plan_change_validation, :if => :"plan_changed?"
  
  # return all plans
  def self.plans
    Plan.all
  end
  
  def self.permissions
    Plan::ALLOWS.keys
  end

  # define permissions methods
  #   can_add_editor?
  #   can_add_site?
  #   can_add_page?
  #
  self.permissions.each do |perm|
    define_method(:"can_add_#{perm}?") do
      self.plan.send(:"can_add_#{perm}?", self)
    end    
  end
  
  # return the previous plan
  def plan_was
    Plan.find(plan_id_was)
  end
  
  # got true if plan has been changed but not saved yet
  def plan_changed?
    plan_id_changed?
  end
  
  def plan_changed_to? compared_plan
    plan_changed? && plan == compared_plan
  end
  
  def plan_change_validation options={}
    plan_was.changes_to(self.plan, self, options)
  end  

  # def plan= value
  #   write_attribute :plan_id, value.id and return if new_record?
  #   raise NoMethodError, "Method shouldn't be called. Use 'set_plan' instead. "
  # end
  # 
  # def plan
  #   Plan.find(self.plan_id)
  # end
  
  def set_plan value, *params
    new_plan = value.kind_of?(Plan) ? value : Plan.find(value)
    return nil if self.invalid? or (self.plan == new_plan)
    general_changes_method = :"_set_#{new_plan.identificator}_plan?"
    self.plan = new_plan if !respond_to?(general_changes_method, true) || send(general_changes_method, *params)
    # write_attribute(:plan_id, new_plan.id) 
    self.plan_changed?
  end
  
  def set_card(card)
    # return false unless self.plan.professional?
    card = ExtCreditCard.new(card) unless card.kind_of?(ExtCreditCard)
    return false if card.invalid?
    recurring_method = plan_changed? ? :update_recurring : :recurring
    PaymentSystem.send(recurring_method, self, card)
    set_card_fields(card)
    Mailer.deliver_credit_card_changes(self)
  end
  

  private
  
  def cancel_recurring
    if plan_was && plan_was.professional?
      PaymentSystem.cancel_recurring(self) 
      self.card_number = nil
      self.card_exp_date = nil
    end
  end

  def set_card_fields(card)
    self.card_number = card.display_number
    self.card_exp_date = Date.new(card.year, card.month, 1)
  end
  
  def _set_professional_plan?(*params)
    Mailer.deliver_plan_change(self)
    true
  end
  
  def _set_free_plan?(*params)
    cgi_params = params.first || {}
    sites = pages = []
    
    if cgi_params[:sites]
      sites = Site.find(cgi_params[:sites]) 
      (self.sites - sites).each { |site| site.destroy }
    end
    
    if cgi_params[:pages]
      pages = Page.find(cgi_params[:pages])      
      (self.pages - pages).each { |page| page.destroy }
    end
    
    self.editors.clear

    cancel_recurring

    Mailer.deliver_plan_change(self)
    true
  end
  
end
# 
# @owner.require_current_password
# @owner.update_attributes(params[:preferences][:owner])
# @message = ['preferences.updated']
# 
# @plan = params[:preferences][:owner][:plan]
# @card = ExtCreditCard.new params[:preferences][:card]
#
# @plan_changed = @plan != @owner.plan
# if @plan == 'professional' && (@owner.plan_changed? || !@card.number.blank?)
#   @card.valid?
#   if @owner.errors.empty? && @card.errors.empty?
#     begin
#       if @owner.plan_changed?
#         @owner.set_plan(Plan::PROFESSIONAL, params)
#         @message = ['plan.upgraded', {:plan_was => @owner.plan_was.name}]
#       else
#         @owner.set_card @card
#       end
#     rescue PaymentSystemError
#       render_message I18n.t('plan.payment_error', 
#         :contact_us => MessageKeywords.contact_us('contact us'), 
#         :support => MessageKeywords.support_email)
#     end
#   end
# end
# 
# unless @owner.errors.empty? && @card.errors.empty?
#   render_errors :preferences_owner => @owner, :preferences_card => @card
# end