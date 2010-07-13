class Subscription < ActiveRecord::Base
  
  default_scope :order => "end_at"
  
  belongs_to :owner
  
  validates_presence_of :start_at
  validates_presence_of :end_at
  validates_presence_of :price
  
  
  
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
#

