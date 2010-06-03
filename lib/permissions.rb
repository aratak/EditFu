module Permissions
  
  # ALL_PERMISSIONS = [ :add_editor, :add_site, :add_page ]
  # 
  # @permissions = []
  
  # def can_add_editor?
  #   return acceptable_plan_for Plan::TRIAL, Plan::UNLIMITEDTRIAL, Plan::PROFESSIONAL
  # end
  # 
  # def can_add_site?
  #   return acceptable_plan_for Plan::TRIAL, Plan::UNLIMITEDTRIAL, Plan::PROFESSIONAL
  #   # return acceptable_plan_for(Plan::SINGLE) && sites.count <= 1
  # end
  # 
  # def can_add_page?
  #   return acceptable_plan_for Plan::TRIAL, Plan::UNLIMITEDTRIAL, Plan::SINGLE, Plan::PROFESSIONAL
  # end
  #
  #
  # def initialize *params, &block
  #   super(*params, &block)
  #   @permissions = ALL_PERMISSIONS.collect{ |p| send("can_#{p}?")  }
  # end
  # 
  # 
  # private
  # 
  # def acceptable_plan_for *plans
  #   plans.include?(plan)
  # end
  
end