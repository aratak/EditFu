class Owner
  
  validate :plan_change_validation, :if => :plan_changed?
  
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
  
  def plan_change_validation options={}
    plan_was.changes_to(self.plan, self, options)
  end  

  def set_plan value, *params
    new_plan = value.kind_of?(Plan) ? value : Plan.find(value)
    return nil if (self.plan == new_plan)
    general_changes_method = :"_set_#{new_plan.identificator}_plan?"
    self.plan = new_plan if !respond_to?(general_changes_method, true) || send(general_changes_method, *params)
    plan_changed?  
  end
  
  private
  
  # def _set_professional_plan?(*params)
  #   true
  # end
  
  def _set_single_plan?(*params)
    cgi_params = params.first || {}
    if cgi_params[:sites]
      sites = Site.find(cgi_params[:sites]) 
      (self.sites - sites).each { |site| site.destroy }
    end
    
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
    self.card.destroy if self.card
    true
  end
  
end