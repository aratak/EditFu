class Plan
  
  def changes_to new_plan, owner, options={}
    general_validation_name = :"_change_to_#{new_plan.identificator}"
    private_validation_name = :"_change_from_#{self.identificator}_to_#{new_plan.identificator}"
    
    return send(private_validation_name, owner, options) if respond_to?(private_validation_name, true)
    return send(general_validation_name, owner, options) if respond_to?(general_validation_name, true)
    return true
  end

  # if plan_id_changed?
  #   if plan.trial?
  #     raise "Invalid plan change" if [Plan::FREE, Plan::PROFESSIONAL].include?(plan_was)
  #   elsif plan.free?
  #     if sites.count { |r| !r.destroyed? } > 1
  #       errors.add_to_base I18n.t("free_plan.site_count")
  #     end
  # 
  #     if pages.count { |r| !r.destroyed? } > 3
  #       errors.add_to_base I18n.t("free_plan.page_count")
  #     end
  #   end
  # end
  

  private
  
  # should change only without editors
  def _change_to_single owner, options={}
    condition = owner.editors.empty?
    owner.errors.add_to_base I18n.t("single_plan.editors_error") unless condition
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