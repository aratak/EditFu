class Owner
  
  has_many :subscriptions
  accepts_nested_attributes_for :subscriptions, :allow_destroy => true
  after_save :create_next_subscription, :if => :next_subscription?
  
  def close_latest_subscription
    return true if subscriptions.empty?
    
    subscriptions.last.update_attribute(:ends_at, Date.today) unless subscriptions.last.ends_at.past?
    true
  end
  
  def create_next_subscription
    return false unless subscription_is_possible?
    close_latest_subscription
    subscriptions.create(:starts_at => Time.now,
                         :ends_at => self.plan.period.month.since,
                         :price => self.plan.price,
                         :plan => self.plan)
    self.hold = false
    self.send(:update_without_callbacks)

    return true                     
  end
  
  def subscription_is_possible?
    # self.plan.payment? || self.plan.trial?
    true
  end
  
  
  def next_subscription?
    plan_changed? || new_record?
  end
  
end