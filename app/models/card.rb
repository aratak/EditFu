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


  after_update :update_recurring
  after_create :recurring
  
  after_save :set_card_fields
  after_save :deliver_credit_card_changes
  before_destroy :cancel_recurring

  
  def initialize(val)
    super
    self.credit_card = val.kind_of?(ExtCreditCard) ? val : ExtCreditCard.new(val)
  end
  
  def recurring
    PaymentSystem.recurring self.owner, self.credit_card
  end
  
  def update_recurring
    PaymentSystem.update_recurring self.owner, self.credit_card
  end
  
  def set_card_fields
    self.display_number = credit_card.display_number                                  # 'XXXX-'*3 + number[-4..-1] 
    self.display_expiration_date = Date.new(credit_card.year, credit_card.month, 1)   # self.expiration_date
  end
  
  def cancel_recurring
    PaymentSystem.cancel_recurring(self)
  end

  
  def deliver_credit_card_changes
    Mailer.deliver_credit_card_changes(self)
  end

  private
  
  def validate
    errors.add_to_base "is invalid" if self.credit_card.invalid?
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
#

