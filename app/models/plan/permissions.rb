class Plan

  ALLOWS = {
    :page   => [FREE, TRIAL, UNLIMITEDTRIAL, SINGLE, PROFESSIONAL],
    :site   => [      TRIAL, UNLIMITEDTRIAL,         PROFESSIONAL],
    :editor => [      TRIAL, UNLIMITEDTRIAL,         PROFESSIONAL]
  }


  # the general method for each can_add_#{permission}?
  #
  #   can_add?(:page, Owner.first)
  #
  def can_add? thing, user
    return false unless general_conditions(thing, user)
    method = :"_can_add_#{thing}?"
    
    return send(method, user) if respond_to?(method, true)
    true
  end

  # Creates method for checking permissions
  #
  #   can_add_page?
  #   can_add_editor?
  #   can_add_site?
  #
  ALLOWS.keys.each do |i|
    define_method(:"can_add_#{i}?") do |user|
      can_add?(i, user)
    end    
  end
  
  private
  
  def general_conditions thing, user
    user.owner? && !deny_plans(thing)
  end
  
  def deny_plans thing
    !ALLOWS[thing.to_sym].include?(self)
  end

  def _can_add_page? user
    !(self == FREE) || (user.pages.count < 3)
  end
  
end