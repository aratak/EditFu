class Subscription < ActiveRecord::Base
  
  default_scope :order => "#{self.table_name}.ends_at"
  
  named_scope :past, :conditions => ["#{self.table_name}.ends_at < ?", Time.now]

  named_scope :starts_in_past, :conditions => ["#{self.table_name}.starts_at < ?", Time.now]
  
  named_scope :in_period, lambda { |date|
    { :conditions => ["#{self.table_name}.starts_at < ? and #{self.table_name}.ends_at > ?", date, date] }
  }
  
  named_scope :ends_todays, :conditions => ["date(#{self.table_name}.ends_at) = date(?)", Time.now]
  
  named_scope :ends_after, lambda { |period|
    date = Date.today + period
    { :conditions => ["date(#{self.table_name}.ends_at) = date(?)", date] }
  }
  
  named_scope :ends_earlier, lambda { |period|
    date = Date.today + period
    { :conditions => ["#{self.table_name}.ends_at < ?", date], :include => [:owner] }
  }
  
  
  
  attr_reader :price_in_dollars
  
  before_create :close_previous_subscirption
  before_create :set_owner_plan

  belongs_to :owner, :autosave => true
  belongs_to :plan
  
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :price
  validates_presence_of :owner_id
  
  
  def self.ends_earlier_than(period)
    self.active.ends_earlier(period)
  end
  
  def self.active date=Time.now
    self.in_period(date)
  end
  
  def self.previous
    past.first
  end
  
  def self.latest
    self.find :last
  end
  
  def close_previous_subscirption
    self.owner.close_latest_subscription
  end
  
  def price_in_dollars
    self.price.to_i / 100
  end

  def price_in_dollars= val
    self.price = (val.to_i * 100).to_i
  end

  def set_owner_plan
    unless self.owner.plan == self.plan
      self.owner.set_plan(self.plan)
      self.owner.send(:update_without_callbacks)
    end
  end
  
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

