class Owner < User

  has_many :sites, :dependent => :destroy
  has_many :pages, :through => :sites
  has_many :editors, :dependent => :destroy
  belongs_to :plan
  has_one :card, :dependent => :destroy, :inverse_of => :owner

  attr_accessor_with_default :card_must_be_present, false

  alias_attribute :subdomain, :domain_name
  accepts_nested_attributes_for :card, :reject_if => :card_shouldnt_be_changed
  
  attr_accessible :domain_name, :company_name, :terms_of_service, :card_attributes, :subscriptions_attributes

  validates_presence_of  :domain_name
  validates_associated :plan 
  validates_associated :card, :if => :card_should_be_changed
  validates_length_of :company_name, :within => 3..255, :allow_blank => true
  validates_uniqueness_of :domain_name, :message => "This domain already taken"
  validates_format_of :domain_name, :with => /^\w+$/
  validates_exclusion_of :domain_name, :in => %w(www admin dev staging)
  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false, :message => 'Read and accept it!'

  concerned_with :associations, :delivers, :plan_migrations, :plan_relation, :subscriptions

  def card_should_be_changed
    has_payment_plan? && card_must_be_present
  end

  def card_shouldnt_be_changed
    !card_should_be_changed
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

