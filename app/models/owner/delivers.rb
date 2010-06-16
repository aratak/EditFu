class Owner

  before_update :deliver_subdomain_changes, :if => :domain_name_changed?
  before_update :deliver_hold, :if => :holded?
  before_update :deliver_owner_email_changes, :if => :email_changed?
  before_update :deliver_plan_changed, :if => :plan_changed?
  before_destroy :account_cancellation


  def self.deliver_scheduled_messages
    deliver_card_expirations
    deliver_cards_have_expired
    deliver_trial_expiration_reminder
    deliver_trial_expirations
  end
  
  def send_confirmation_instructions
    Mailer.deliver_signup(self)
  end
  
  protected
  
  
  def deliver_plan_changed
    Mailer.deliver_plan_change(self)
  end
  
  def deliver_subdomain_changes
    Mailer.deliver_owner_subdomain_changes(self)
    editors.each do |editor|
      Mailer.deliver_editor_subdomain_changes(self, editor)
    end
  end
  
  def deliver_hold
    Mailer.deliver_hold(self)
  end
  
  def account_cancellation
    Mailer.deliver_account_cancellation(self)
  end
  
  def deliver_owner_email_changes
    Mailer.deliver_owner_email_changes(self)
  end
  
  def self.deliver_card_expirations
    Owner.find_all_by_card_exp_date(15.days.from_now.to_date).each do |owner|
      Mailer.deliver_card_expiration(owner)
    end
  end

  def self.deliver_cards_have_expired
    Owner.find_all_by_card_exp_date(Date.today).each do |owner|
      Mailer.deliver_card_has_expired(owner)
    end
  end

  def self.deliver_trial_expirations
    conditions = ["plan = '?' AND DATE(confirmed_at) = ?", Plan::TRIAL.id, 30.days.ago.to_date]
    Owner.all(:conditions => conditions).each do |owner|
      Mailer.deliver_trial_expiration(owner)
    end
  end
  
  def self.deliver_trial_expiration_reminder
    conditions = ["plan = '?' AND DATE(confirmed_at) = ?", Plan::TRIAL.id, 27.days.ago.to_date]
    Owner.all(:conditions => conditions).each do |owner|
      Mailer.deliver_trial_expiration_reminder(owner)
    end
  end
  
end