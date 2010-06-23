class Card < ActiveRecord::Base

  attr_accessor :first_name, :last_name, :expiration, 
                :number, :verification_value, :zip, 
                :credit_card

  belongs_to :owner

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :expiration
  validates_presence_of :number
  validates_presence_of :verification_value
  validates_presence_of :zip


  before_validation_on_update :update_recurring
  before_validation_on_create :recurring
  before_validation :set_credit_card
  
  # before_save :set_card_fields
  after_save :deliver_credit_card_changes
  before_destroy :cancel_recurring

  
  def set_credit_card
    self.credit_card = ExtCreditCard.new(attributes_for_credit_card)
  end
  
  def recurring
    begin
      PaymentSystem.recurring(self.owner, self)
      set_card_fields
    rescue PaymentSystemError
      errors.add :credit_card, "is invalid"
    end    
  end
  
  def update_recurring
    begin
      PaymentSystem.update_recurring(self.owner, self)
      set_card_fields
    rescue PaymentSystemError
      errors.add :credit_card, "is invalid"
    end    
  end
  
  def set_card_fields
    self.display_number = credit_card.display_number                                  # 'XXXX-'*3 + number[-4..-1] 
    self.display_expiration_date = Date.new(credit_card.year, credit_card.month, 1)   # self.expiration_date
  end
  
  def cancel_recurring
    PaymentSystem.cancel_recurring(self.owner)
  end

  
  def deliver_credit_card_changes
    Mailer.deliver_credit_card_changes(self.owner)
  end

  private

  def validate
    errors.add :credit_card, "is invalid" if credit_card.invalid?
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

