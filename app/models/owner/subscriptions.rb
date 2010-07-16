class Owner
  
  has_many :subscriptions
  accepts_nested_attributes_for :subscriptions, :allow_destroy => true
  after_update :create_next_subscription, :if => :next_subscription?
  after_create :create_next_subscription
  
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
    return true                     
  end
  
  def subscription_is_possible?
    # self.plan.payment? || self.plan.trial?
    true
  end
  
  
  def next_subscription?
    plan_changed?
  end
  
  # def holded?
  #   hold? && plan_changed?
  # end
  # 
  # def unholded?
  #   !holded?
  # end
  
  def hold
    return true if self.subscriptions.empty?
    return true if self.subscriptions.last.ends_at.nil?
    self.subscriptions.last.ends_at < Time.now
  end
  alias_method :hold?, :hold
  
  def hold= val
    if [true, 1, '1', 't', 'T', 'true', 'TRUE'].include?(val)
      self.close_latest_subscription 
    else
      self.create_next_subscription
    end
  end
  
  # def billing_day
  #   ActiveSupport::Deprecation.warn("the method 'billing_day' will be deplicated")
  #   if confirmed_at
  #     confirmed_at.mday > 28 ? 1 : confirmed_at.mday 
  #   end
  # end

  def prev_billing_date
    # ActiveSupport::Deprecation.warn("the method 'prev_billing_date' will be deplicated")
    # d = next_billing_date << 1
    # d <= confirmed_at.to_date ? nil : d
    # subscriptions[-2].ends_at
    
    subscriptions.last.try(:starts_at).try(:to_date)
  end

  def next_billing_date(date = Date.today)
    # ActiveSupport::Deprecation.warn("the method 'next_billing_date' will be deplicated")
    # this_bd = Date.new(date.year, date.month, billing_day)
    # this_bd.past? ? this_bd.next_month : this_bd

    subscriptions.find(:last).try(:ends_at)
  end

  # def prof_plan_begins_at
  #   ActiveSupport::Deprecation.warn("the method 'prof_plan_begins_at' will be deplicated")
  #   if !plan.professional?
  #     next_billing_date
  #   else
  #     next_billing_date(confirmed_at)
  #   end
  # end

  def trial_period_expired?
    plan.trial? && hold?
  end  
  
end