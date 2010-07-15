class Subscription < ActiveRecord::Base
  
  default_scope :order => "ends_at"

  attr_reader :price_in_dollars

  belongs_to :owner
  belongs_to :plan
  
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :price_in_dollars
  validates_presence_of :owner_id
  
  before_create :close_previous_subscirption
  
  def close_previous_subscirption
    self.owner.close_latest_subscription
  end
  
  def price_in_dollars
    self.price / 100
  end

  def price_in_dollars= val
    p "="*50
    self.price = (val.to_i * 100).to_i
  end

  
  # def set_plan
  #   self.plan = self.owner.plan if self.plan.nil?
  # end
  #   
  # return true if plan is payment, 
  # so subscription can be created
  # def possible?
  #   self.owner.subscription_is_possible?
  # end
  
end



# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  owner_id   :integer(4)
#  starts_at  :datetime
#  ends_at    :datetime
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer(4)
#

