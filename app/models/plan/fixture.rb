class Plan
  
  # there are list of all plans
  create :id => 1, :name => "Trial",          :price => 0,     :display_name => "Trial"
  create :id => 2, :name => "Free",           :price => 0,     :display_name => "Free"
  create :id => 3, :name => "UnlimitedTrial", :price => 0,     :display_name => "Buddy"
  create :id => 4, :name => "Single",         :price => 300,   :display_name => "Single"
  create :id => 5, :name => "Professional",   :price => 1500, :display_name => "Pro"
  
  PAYMENTS = [SINGLE, PROFESSIONAL]
  UNPAYMENTS = Plan.all - PAYMENTS

  def payment?
    PAYMENTS.include? self
  end
  
  def description
    av = ActionView::Base.new(Rails::Configuration.new.view_path)
    av.render :partial => "plans/description/#{self.identificator}"
  end
  
  def price_in_dollars
    price / 100
  end
  
end