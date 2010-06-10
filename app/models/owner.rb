class Owner < User
  # @@plans = %w(trial unlimited_trial free professional)

  # acts_as_audited :only => [:plan]
  
  # before_validation_on_create :set_default_domain_name


  attr_accessible :domain_name, :company_name, :terms_of_service
  
  concerned_with :migrations

  # Associations
  has_many :sites, :dependent => :destroy
  has_many :pages, :through => :sites
  has_many :editors, :dependent => :destroy
  belongs_to :plan
  
  # include Plan::Migrations
  before_update :plan_change_validation, :if => :"plan_changed?"

  # Validations
  validates_presence_of  :domain_name #, :plan
  validates_associated :plan 
  # validates_presence_of :company_name
  validates_length_of :company_name, :within => 3..255, :allow_blank => true
  validates_uniqueness_of :domain_name
  validates_format_of :domain_name, :with => /^\w+$/
  validates_exclusion_of :domain_name, :in => %w(www admin)

  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false, :message => 'Read and accept it!'



  def trial_period_end
    30.days.since(confirmed_at).to_date
  end

  def trial_period_expired?
    plan.trial? && trial_period_end.past?
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
    sites.find_by_id site_id
  end

  def find_page(site_id, page_id)
    pages.find :first, :conditions => { :id => page_id, :site_id => site_id }
  end

  def send_confirmation_instructions
    Mailer.deliver_signup(self)
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
    if !plan.professional?
      next_billing_date
    else
      next_billing_date(confirmed_at)
    end
  end

  def self.deliver_scheduled_messages
    deliver_card_expirations
    deliver_cards_have_expired
    deliver_trial_expiration_reminder
    deliver_trial_expirations
  end

  protected

  def before_update
    if hold && hold_changed?
      Mailer.deliver_hold(self)
    end

    deliver_subdomain_changes if domain_name_changed?
    Mailer.deliver_owner_email_changes(self) if email_changed?
  end

  def before_destroy
    cancel_recurring
    Mailer.deliver_account_cancellation(self)
  end

  # def validate
  #   super 
    # if plan_id_changed?
    #   if plan.trial?
    #     raise "Invalid plan change" if [Plan::FREE, Plan::PROFESSIONAL].include?(plan_was)
    #   elsif plan.free?
    #     if sites.count { |r| !r.destroyed? } > 1
    #       errors.add_to_base I18n.t("free_plan.site_count")
    #     end
    # 
    #     if pages.count { |r| !r.destroyed? } > 3
    #       errors.add_to_base I18n.t("free_plan.page_count")
    #     end
    #   end
    # end
  # end


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
    conditions = ["plan = '?' AND DATE(confirmed_at) = ?", Plan::TRIAL.id, 30.days.ago.to_date]
    Owner.all(:conditions => conditions).each do |owner|
      Mailer.deliver_trial_expiration(owner)
    end
  end
  
  def self.deliver_trial_expiration_reminder
    conditions = ["plan = '?' AND DATE(confirmed_at) = ?", Plan::TRIAL.id, 27.days.ago.to_date]
    Owner.all(:conditions => conditions).each do |owner|
      Mailer.deliver_trial_expiration_reminder(owner)
    end
  end

  def deliver_subdomain_changes
    Mailer.deliver_owner_subdomain_changes(self)
    editors.each do |editor|
      Mailer.deliver_editor_subdomain_changes(self, editor)
    end
  end
  
end


# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  email                :string(100)     not null
#  encrypted_password   :string(40)
#  password_salt        :string(20)
#  confirmation_token   :string(20)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(20)
#  remember_token       :string(20)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  domain_name          :string(255)
#  owner_id             :integer(4)
#  type                 :string(10)      not null
#  card_number          :string(20)
#  subscription_id      :string(13)
#  enabled              :boolean(1)      default(TRUE), not null
#  user_name            :string(255)
#  card_exp_date        :date
#  company_name         :string(255)
#  hold                 :boolean(1)
#  plan_id              :integer(4)
#

