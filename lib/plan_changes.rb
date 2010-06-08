module PlanChanges

  def can_be_changed_to new_plan, owner, options={}

    general_validation_name = :"_change_to_#{new_plan.identificator}"
    private_validation_name = :"_change_from_#{self.identificator}_to_#{new_plan.identificator}"
    
    return send(private_validation_name, owner, options) if respond_to?(private_validation_name, true)
    return send(general_validation_name, owner, options) if respond_to?(general_validation_name, true)
    return true
  end

  private
  
  # should change only without editors
  def _change_to_single owner, options={}
    owner.editors.empty?
  end
  
  # shouldn't chabge to trial
  def _change_to_trial owner, options={}
    false
  end

  # should change only without editors 
  #  and with sites less than 3
  def _change_to_free owner, options={}
    (owner.sites.count < 3) && owner.editors.empty?
  end

end