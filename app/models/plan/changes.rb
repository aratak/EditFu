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
    owner.editors.empty?
  end
  
  # shouldn't chabge to trial
  def _change_to_trial owner, options={}
    false
  end
  
  # should change only without editors 
  #  and with sites less than 3
  def _change_to_free owner, options={}
    editors.clear
    
    (owner.sites.count == 1) && owner.editors.empty?
  end
  
end