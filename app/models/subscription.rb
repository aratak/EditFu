class Subscription < ActiveRecord::Base
  
  belongs_to :owner
  
  validates_presence_of :start_at
  validates_presence_of :end_at
  validates_presence_of :price
  
  
  
end
