class Owner
  
  has_many :subscriptions
  accepts_nested_attributes_for :subscriptions, :allow_destroy => true
  after_update :create_next_subscription, :if => :next_subscription?
  after_create :create_next_subscription
  
  def close_latest_subscription
    return true if subscriptions.empty?
    
    subscriptions.last.update_attributes(:ends_at => Time.now) unless subscriptions.last.ends_at.past?
    true
  end
  
  def create_next_subscription
    return false unless subscription_is_possible?
    close_latest_subscription
    subscriptions.create(:starts_at => Time.now,
                         :ends_at => self.plan.period.month.since,
                         :price => self.plan.price,
                         :plan => self.plan)
    return true                     
  end
  
  def subscription_is_possible?
    # self.plan.payment? || self.plan.trial?
    true
  end
  
  def next_subscription?
    plan_changed?
  end
  
  def hold
    return true if self.subscriptions.empty?
    self.subscriptions.latest.ends_at < Time.now
  end
  alias_method :hold?, :hold
  
  def credit_card_expired?
    self.plan.payment? && self.card.display_expiration_date.past?
  end
  
  def hold= val
    if [true, 1, '1', 't', 'T', 'true', 'TRUE'].include?(val)
      self.close_latest_subscription 
    else
      self.create_next_subscription
    end
  end
  
  def prev_billing_date
    subscriptions.last.try(:starts_at).try(:to_date)
  end

  def next_billing_date(date = Date.today)
    subscriptions.last.try(:ends_at).try(:to_date)
  end

  def trial_period_expired?
    plan.trial? && hold?
  end  
  
end