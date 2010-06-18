class Owner < User

  has_many :sites, :dependent => :destroy
  has_many :pages, :through => :sites
  has_many :editors, :dependent => :destroy
  belongs_to :plan
  has_one :card, :dependent => :destroy, :autosave => true

  alias_attribute :subdomain, :domain_name
  accepts_nested_attributes_for :card, :reject_if => :has_no_payment_plan?
  attr_accessible :domain_name, :company_name, :terms_of_service, :card_attributes

  validates_presence_of  :domain_name
  validates_associated :plan 
  validates_associated :card
  validates_length_of :company_name, :within => 3..255, :allow_blank => true
  validates_uniqueness_of :domain_name
  validates_format_of :domain_name, :with => /^\w+$/
  validates_exclusion_of :domain_name, :in => %w(www admin dev staging)
  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false, :message => 'Read and accept it!'
  # validates_presence_of :card_number, :if => :plan_is_professional?

  concerned_with :card_relation, :associations, :delivers, :plan_migrations, :plan_relation

  def holded?
    hold && hold_changed?
  end
  
  def unholded?
    !holded?
  end

  def has_payment_plan?
    Plan::PAYMENTS.include?(self.plan)
  end
  
  def has_no_payment_plan?
    !has_payment_plan?
  end
  


  def trial_period_end
    logger.warn("the method 'trial_period_end' will be deplicated")
    30.days.since(confirmed_at).to_date
  end

  def trial_period_expired?
    logger.warn("the method 'trial_period_end' will be deplicated")
    plan.trial? && trial_period_end.past?
  end  

  def billing_day
    logger.warn("the method 'trial_period_end' will be deplicated")
    if confirmed_at
      confirmed_at.mday > 28 ? 1 : confirmed_at.mday 
    end
  end

  def prev_billing_date
    logger.warn("the method 'trial_period_end' will be deplicated")
    d = next_billing_date << 1
    d <= confirmed_at.to_date ? nil : d
  end

  def next_billing_date(date = Date.today)
    logger.warn("the method 'trial_period_end' will be deplicated")
    this_bd = Date.new(date.year, date.month, billing_day)
    this_bd.past? ? this_bd.next_month : this_bd
  end

  def prof_plan_begins_at
    logger.warn("the method 'trial_period_end' will be deplicated")
    if !plan.professional?
      next_billing_date
    else
      next_billing_date(confirmed_at)
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

