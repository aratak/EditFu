class Plan < ActiveHash::Base
  include ActiveHash::Enum
  fields :name, :price
  enum_accessor :name
  
  include PlanChanges

  # there are list of all plans
  create :id => 1, :name => "Trial", :price => BigDecimal.new("0")
  create :id => 2, :name => "Free", :price => BigDecimal.new("0")
  create :id => 3, :name => "UnlimitedTrial", :price => BigDecimal.new("0")
  create :id => 4, :name => "Single", :price => BigDecimal.new("3")
  create :id => 5, :name => "Professional", :price => BigDecimal.new("15")

  CURRENCY = "$"
  
  ALLOWS = {
    :page   => [FREE, TRIAL, UNLIMITEDTRIAL, SINGLE, PROFESSIONAL],
    :site   => [      TRIAL, UNLIMITEDTRIAL,         PROFESSIONAL],
    :editor => [      TRIAL, UNLIMITEDTRIAL,         PROFESSIONAL]
  }
  
  # return underscored name
  #   Plan::FREE.identificator == "free"
  #   Plan::TRIAL.identificator == "trial"
  #   Plan::UNLIMITEDTRIAL.identificator == "unlimitedtrial"
  # etc.
  def identificator
    self.name.underscore
  end
  
  # define predicatds 
  #   plan.free?, plan.trial?, etc. 
  #   plan.not_free?, plan.not_trial?
  all.each do |p|
    
    define_method(:"#{p.identificator}?") do
      self.name == p.name
    end    

    define_method(:"not_#{p.identificator}?") do
      self.name != p.name
    end    

  end
  
  # return string variant of price
  # with '$' symbol as prefix
  def str_price
    "#{CURRENCY} #{self.price}"
  end
  
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