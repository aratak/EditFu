class Owner < User
  @@plans = %w(trial free professional)

  # Associations
  has_many :sites, :dependent => :destroy
  has_many :pages, :through => :sites
  has_many :editors, :dependent => :destroy

  # Validations
  validates_presence_of  :plan
  validates_inclusion_of :plan, :in => @@plans

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
  
  def site_pages(site)
    site.pages
  end

  def add_editor(email)
    name = email[0, email.index('@')]
    editor = Editor.new :name => name, :email => email
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
    Mailer.deliver_owner_confirmation_instructions(self)
  end
      
  def set_professional_plan(card)
    if plan != "professional"
      self.plan = "professional"
      recurring(card)
    end
  end

  def set_free_plan(sites, pages)
    (self.sites - sites).each { |site| site.destroy }
    (self.pages - pages).each { |page| page.destroy }

    cancel_recurring

    self.plan = "free"
    self.save!
  end

  protected

  def before_save
    if plan == "free" && plan_changed?
      editors.clear
    end
  end

  def before_destroy
    cancel_recurring
  end

  def validate
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
    save!
  end

  def cancel_recurring
    PaymentSystem.cancel_recurring(self) if self.plan == 'professional'
    self.card_number = nil
  end
end
