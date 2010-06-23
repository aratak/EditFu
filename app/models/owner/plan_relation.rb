class Owner
  
  # current plan is payment
  def has_payment_plan?
    Plan::PAYMENTS.include?(self.plan)
  end
  
  # curent plans is not payment
  def has_no_payment_plan?
    !has_payment_plan?
  end
  alias_method :hasnt_payment_plan?, :has_no_payment_plan?
  
  
  # return the previous plan
  def plan_was
    Plan.find(plan_id_was)
  end
  
  # got true if plan has been changed but not saved yet
  def plan_changed?
    plan_id_changed?
  end
  
  def plan_changed_to? compared_plan
    plan_changed? && plan == compared_plan
  end
  
  def plan_was?(compared_plan)
    plan_changed? && (plan_was == compared_plan)
  end
  
  
  # define predicatds 
  #   owner.plan_was_free?, owner.plan_was_trial?, owner.plan_was_professional? ...
  #   owner.plan_was_not_free?, owner.plan_was_not_trial? ...
  #   owner.plan_wasnt_free?, owner.plan_wasnt_trial? ...
  # etc...
  Plan.all.each do |pl|
    
    define_method(:"plan_is_#{pl.identificator}?") do
      plan == pl
    end
    
    define_method(:"plan_changed_to_#{pl.identificator}?") do
      plan_changed_to?(pl)
    end
    
    define_method(:"plan_was_#{pl.identificator}?") do
      plan_was?(pl)
    end

    define_method(:"plan_was_not_#{pl.identificator}?") do
      !self.send(:"plan_was_#{pl.identificator}?")
    end
    alias_method :"plan_wasnt_#{pl.identificator}?", :"plan_was_not_#{pl.identificator}?"

  end
  
end