class Owner
  
  # return all plans
  def self.plans
    Plan.all
  end
  
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
  Plan.all.each do |p|
    
    define_method(:"plan_is_#{p.identificator}?") do
      plan == p
    end
    
    define_method(:"plan_changed_to_#{p.identificator}?") do
      plan_changed_to?(p)
    end
    
    define_method(:"plan_was_#{p.identificator}?") do
      plan_was?(p)
    end

    define_method(:"plan_was_not_#{p.identificator}?") do
      !self.send(:"plan_was_#{p.identificator}?")
    end
    alias_method :"plan_wasnt_#{p.identificator}?", :"plan_was_not_#{p.identificator}?"

  end
  
end