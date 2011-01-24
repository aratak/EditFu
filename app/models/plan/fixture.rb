class Plan
  
  # there are list of all plans
  create :id => 1, :name => "Trial",          :price => 0,     :display_name => "Trial"   , :period => 1
  create :id => 2, :name => "Free",           :price => 0,     :display_name => "Free"    , :period => 144
  create :id => 3, :name => "UnlimitedTrial", :price => 0,     :display_name => "Buddy"   , :period => 144
  create :id => 4, :name => "Single",         :price => 300,   :display_name => "Single"  , :period => 1
  create :id => 5, :name => "Professional",   :price => 900,   :display_name => "Pro"     , :period => 1
  
  PAYMENTS = [SINGLE, PROFESSIONAL]
  UNPAYMENTS = Plan.all - PAYMENTS
  PERIODED = [SINGLE, PROFESSIONAL, TRIAL]

  def payment?
    PAYMENTS.include? self
  end
  
  def perioded?
    PERIODED.include? self
  end
  
  def payment_style_class
    payment? ? :payment : :unpayment
  end
  
  def current_style_class(owner)
    is_current?(owner) ? :current : :not_current
  end
  
  def is_current?(owner)
    self == owner.plan_was
  end
  
  def description
    av = ActionView::Base.new(Rails::Configuration.new.view_path)
    av.render :partial => "plans/description/#{self.identificator}"
  end
  
  def price_in_dollars
    price / 100
  end
  
end