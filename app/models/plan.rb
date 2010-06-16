class Plan < ActiveHash::Base
  include ActiveHash::Enum
  fields :name, :price
  enum_accessor :name
  CURRENCY = "$"
  
  concerned_with :changes, :fixture, :permissions

  # return underscored name
  #   Plan::FREE.identificator == "free"
  #   Plan::TRIAL.identificator == "trial"
  #   Plan::UNLIMITEDTRIAL.identificator == "unlimitedtrial"
  # etc.
  def identificator
    self.name.underscore
  end
  
  def label_tag_name
    "owner_plan_id_#{self.id}"
  end
  
  # define predicatds 
  #   plan.free?, plan.trial?, etc. 
  #   plan.not_free?, plan.not_trial?
  all.each do |p|
    
    define_method(:"#{p.identificator}?") do
      self.name == p.name
    end    

    define_method(:"not_#{p.identificator}?") do
      !self.send(:"#{p.identificator}?")
    end    

  end
  
  # return string variant of price
  # with '$' symbol as prefix
  def str_price
    "#{CURRENCY} #{self.price}"
  end
  
end