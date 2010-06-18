class Plan
  
  def changes_to new_plan, owner, options={}
    general_validation_name = :"_change_to_#{new_plan.identificator}"
    private_validation_name = :"_change_from_#{self.identificator}_to_#{new_plan.identificator}"
    
    return send(private_validation_name, owner, options) if respond_to?(private_validation_name, true)
    return send(general_validation_name, owner, options) if respond_to?(general_validation_name, true)
    return true
  end


  private
  
  # should change only without editors
  def _change_to_single owner, options={}
    condition = owner.sites.count <= 1
    owner.errors.add_to_base I18n.t("single_plan.sites_error") unless condition
    condition
  end
  
  # shouldn't chabge to trial
  def _change_to_trial owner, options={}
    owner.errors.add_to_base I18n.t("plan.trial_set_error")
    false
  end
  
  # should change only without editors 
  #  and with sites less than 3
  def _change_to_free owner, options={}
    sites_condition = (owner.sites.count <= 1)
    editors_condition = owner.editors.empty?
    pages_condition = (owner.pages.count <= 3)
    
    owner.errors.add_to_base I18n.t("free_plan.sites_error") unless sites_condition
    owner.errors.add_to_base I18n.t("free_plan.editors_error") unless editors_condition
    owner.errors.add_to_base I18n.t("free_plan.pages_error") unless pages_condition
    
    sites_condition && editors_condition && pages_condition
  end
  
end