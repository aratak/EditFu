class Card < ActiveRecord::Base


  @first_name = ""
  attr_accessor :first_name, :last_name, :expiration, 
                :number, :verification_value, :zip, 
                :credit_card

  belongs_to :owner

  validates_presence_of :first_name, :on => :create
  validates_presence_of :last_name, :on => :create
  validates_presence_of :expiration, :on => :create
  validates_presence_of :number, :on => :create
  validates_presence_of :verification_value, :on => :create
  validates_presence_of :zip, :on => :create
  
  # after_validation :set_credit_card
  # after_validation_on_create :recurring
  # after_validation_on_update :update_recurring
  # after_validation :subscription_validation

  before_save :set_credit_card
  before_create :recurring
  before_update :update_recurring
  before_save :subscription_validation
  
  before_save :set_display_card_fields
  after_save :deliver_credit_card_changes
  before_destroy :cancel_recurring

  def deliver_credit_card_changes
    Mailer.deliver_credit_card_changes(self.owner)
  end

  def price
    self.owner.plan.price unless owner.nil?
  end

  private

  def set_display_card_fields
    return false if first_name.nil? || first_name.empty?
    self.display_number = self.credit_card.display_number
    self.display_expiration_date = Date.new(credit_card.year, credit_card.month, 1)
  end

  def set_credit_card
    self.credit_card = ExtCreditCard.new(attributes_for_credit_card)
    # credit_card_validation
    # send(new_record? ? :recurring : :update_recurring)
    # set_display_card_fields
  end
  
  def credit_card_validation
    errors.add :credit_card, "is invalid" if self.credit_card.invalid?
  end
  
  def recurring
    begin
      PaymentSystem.recurring(self)
      # subscription_validation
      true
    rescue PaymentSystemError
      errors.add :credit_card, "is invalid"
      false
    end    
  end
  
  def update_recurring
    begin
      PaymentSystem.update_recurring(self)
      # subscription_validation
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
    errors.add(:subscription_id, "Required.") if self.subscription_id.nil? || self.subscription_id.empty?
  end


  def attributes_for_credit_card
    result = {}
    [:first_name, :last_name, :expiration, 
    :number, :verification_value, :zip].map do |attr_name|
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
#  display_expiration_date :string(255)
#  subscription_id         :string(255)
#

