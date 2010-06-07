module PlanChanges
  
  def self.included m
    return unless m < ActionController::Base
    m.before_update :plan_change_validation, :if => :"plan_changed?"
  end
  
  # return the previous plan
  def plan_was
    Plan.find plan_id_was
  end
  
  # got true if plan has been changed but not saved yet
  def plan_changed?
    plan_id_changed?
  end
  
  def plan_change_validation
    plan_was.can_be_changed_to(plan, self, options={})
  end
  
end