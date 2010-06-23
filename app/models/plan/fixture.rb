class Plan
  
  # there are list of all plans
  create :id => 1, :name => "Trial",            :price => BigDecimal.new("0"),    :display_name => "Trial"
  create :id => 2, :name => "Free",             :price => BigDecimal.new("0"),    :display_name => "Free"
  create :id => 3, :name => "UnlimitedTrial",   :price => BigDecimal.new("0"),    :display_name => "Buddy"
  create :id => 4, :name => "Single",           :price => BigDecimal.new("3"),    :display_name => "Single"
  create :id => 5, :name => "Professional",     :price => BigDecimal.new("15"),   :display_name => "Pro"
  
  PAYMENTS = [SINGLE, PROFESSIONAL]
  UNPAYMENTS = Plan.all - PAYMENTS

  def payment?
    PAYMENTS.include? self
  end
  
  def description
    av = ActionView::Base.new(Rails::Configuration.new.view_path)
    av.render :partial => "plans/description/#{self.identificator}"
  end
  
end