class Subscription < ActiveRecord::Base
  
  default_scope :order => "ends_at"

  belongs_to :owner
  belongs_to :plan
  
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :price
  validates_presence_of :owner_id
  
  before_create :close_previous_subscirption
  
  def close_previous_subscirption
    self.owner.close_latest_subscription
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
#  start_at   :date
#  end_at     :date
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer(4)
#

