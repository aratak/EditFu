class Card < ActiveRecord::Base
  FIELDS = [:first_name, :last_name, :expiration, :number, :verification_value, :zip]

  attr_accessor *(FIELDS + [:credit_card] - [:expiration])

  belongs_to :owner

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :display_expiration_date
  validates_presence_of :number
  validates_presence_of :verification_value
  validates_presence_of :zip
  
  # validates_format_of :expiration, :with => /^\d{2}\/\d{4}$/
  
  before_save :set_credit_card
  before_create :recurring
  before_update :update_recurring
  before_create :subscription_validation
  
  before_save :set_display_card_fields
  after_save :deliver_credit_card_changes
  before_destroy :cancel_recurring

  def deliver_credit_card_changes
    Mailer.deliver_credit_card_changes(self.owner)
  end

  def price
    self.owner.plan.price unless owner.nil?
  end
  
  def expiration
    display_expiration_date.strftime("%m/%Y")
  end
  
  private

  def set_display_card_fields
    return true if !changed?
    self.display_number = self.credit_card.display_number
  end

  def set_credit_card
    self.credit_card = ExtCreditCard.new(attributes_for_credit_card)
    credit_card_validation
  end
  
  def credit_card_validation
    errors.add :credit_card, "is invalid" if self.credit_card.invalid?
  end
  
  def recurring
    begin
      PaymentSystem.recurring(self)
      true
    rescue PaymentSystemError
      errors.add :credit_card, "is invalid"
      false
    end    
  end
  
  def update_recurring
    begin
      PaymentSystem.cancel_recurring(self)
      PaymentSystem.recurring(self)
      true
    rescue PaymentSystemError
      errors.add :credit_card, "is invalid"
      false
    end    
  end
  
  def cancel_recurring
    PaymentSystem.cancel_recurring(self)
    true
  end

  def subscription_validation
    errors.add(:credit_card, "is invalid.") if self.subscription_id.nil? || self.subscription_id.empty?
  end


  def attributes_for_credit_card
    result = {}
    FIELDS.map do |attr_name|
      result[attr_name] = self.send(attr_name)
    end
    result
  end
  
end


# == Schema Information
#
# Table name: cards
#
#  id                      :integer(4)      not null, primary key
#  owner_id                :integer(4)
#  display_number          :string(255)
#  display_expiration_date :date
#  subscription_id         :string(255)
#

