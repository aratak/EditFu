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

  def trial_period_expired?
    plan == 'trial' && 30.days.since(confirmed_at).past?
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
      recurring(card)

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
      cancel_recurring
      recurring(card)
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

  def next_billing_date
    today = Date.today
    this_bd = Date.new(today.year, today.month, billing_day)
    this_bd.past? ? this_bd.next_month : this_bd
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

  def recurring(card)
    PaymentSystem.recurring(self, card)
    self.card_number = card.display_number
  end

  def cancel_recurring
    PaymentSystem.cancel_recurring(self) if self.plan == 'professional'
    self.card_number = nil
  end

  def deliver_subdomain_changes
    Mailer.deliver_admin_subdomain_changes(self)
    editors.each do |editor|
      Mailer.deliver_editor_subdomain_changes(self, editor)
    end
  end
end
