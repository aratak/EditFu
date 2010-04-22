class Owner < User
  @@plans = %w(trial free professional)

  acts_as_audited :only => [:plan]

  attr_accessible :domain_name

  # Associations
  has_many :sites, :dependent => :destroy
  has_many :pages, :through => :sites
  has_many :editors, :dependent => :destroy

  # Validations
  validates_presence_of  :plan, :domain_name
  validates_inclusion_of :plan, :in => @@plans
  validates_uniqueness_of :domain_name
  validates_format_of :domain_name, :with => /^\w+$/
  validates_exclusion_of :domain_name, :in => %w(www admin)

  # Methods
  def self.plans
    @@plans
  end

  def can_add_editor?
    plan != "free"
  end

  def can_add_site?
    !(plan == "free" && sites.count >= 1)
  end

  def can_add_page?
    !(plan == "free" && pages.count >= 3)
  end

  def trial_period_end
    30.days.since(confirmed_at).to_date
  end

  def trial_period_expired?
    plan == 'trial' && trial_period_end.past?
  end  
  
  def subdomain
    domain_name.downcase
  end
  
  def site_pages(site)
    site.pages
  end

  def add_editor(email)
    editor_name = email.to_s.gsub(/@.*/, "")
    editor = Editor.new :user_name => editor_name, :email => email
    editor.owner = self
    editor.save
    editor
  end

  def find_site(site_id)
    sites.find site_id
  end

  def find_page(site_id, page_id)
    find_site(site_id).pages.find page_id
  end

  def send_confirmation_instructions
    Mailer.deliver_signup(self)
  end
      
  def set_professional_plan(card)
    if plan != "professional"
      self.plan = "professional"
      PaymentSystem.recurring(self, card)
      set_card_fields(card)

      Mailer.deliver_plan_change(self)
      save!
    end
  end

  def set_free_plan(sites, pages)
    if plan != 'free'
      (self.sites - sites).each { |site| site.destroy }
      (self.pages - pages).each { |page| page.destroy }

      cancel_recurring

      self.plan = "free"
      Mailer.deliver_plan_change(self)
      self.save
    end
  end

  def set_card(card)
    if plan == "professional"
      PaymentSystem.update_recurring(self, card)
      set_card_fields(card)
      Mailer.deliver_credit_card_changes(self)
      save!
    end
  end

  def billing_day
    if confirmed_at
      confirmed_at.mday > 28 ? 1 : confirmed_at.mday 
    end
  end

  def prev_billing_date
    d = next_billing_date << 1
    d <= confirmed_at.to_date ? nil : d
  end

  def next_billing_date(date = Date.today)
    this_bd = Date.new(date.year, date.month, billing_day)
    this_bd.past? ? this_bd.next_month : this_bd
  end

  def prof_plan_begins_at
    if plan != 'professional'
      next_billing_date
    else
      next_billing_date(confirmed_at)
    end
  end

  def self.deliver_scheduled_messages
    deliver_card_expirations
    deliver_cards_have_expired
    deliver_trial_expirations
  end

  protected

  def before_update
    if plan == "free" && plan_changed?
      editors.clear
    end
    deliver_subdomain_changes if domain_name_changed?
    Mailer.deliver_owner_email_changes(self) if email_changed?
  end

  def before_destroy
    cancel_recurring
    Mailer.deliver_account_cancellation(self)
  end

  def validate
    super 
    if plan_changed?
      if plan == "trial"
        raise "Invalid plan change" if ["free", "professional"].include?(plan_was)
      elsif plan == "free"
        if sites.count { |r| !r.destroyed? } > 1
          errors.add_to_base I18n.t("free_plan.site_count")
        end

        if pages.count { |r| !r.destroyed? } > 3
          errors.add_to_base I18n.t("free_plan.page_count")
        end
      end
    end
  end

  def cancel_recurring
    if self.plan == 'professional'
      PaymentSystem.cancel_recurring(self) 
      self.card_number = nil
      self.card_exp_date = nil
    end
  end

  def set_card_fields(card)
    self.card_number = card.display_number
    self.card_exp_date = Date.new(card.year, card.month, 1)
  end

  def self.deliver_card_expirations
    Owner.find_all_by_card_exp_date(15.days.from_now.to_date).each do |owner|
      Mailer.deliver_card_expiration(owner)
    end
  end

  def self.deliver_cards_have_expired
    Owner.find_all_by_card_exp_date(Date.today).each do |owner|
      Mailer.deliver_card_has_expired(owner)
    end
  end

  def self.deliver_trial_expirations
    conditions = ["plan = 'trial' AND DATE(confirmed_at) = ?", 30.days.ago.to_date]
    Owner.all(:conditions => conditions).each do |owner|
      Mailer.deliver_trial_expiration(owner)
    end
  end

  def deliver_subdomain_changes
    Mailer.deliver_owner_subdomain_changes(self)
    editors.each do |editor|
      Mailer.deliver_editor_subdomain_changes(self, editor)
    end
  end
end
