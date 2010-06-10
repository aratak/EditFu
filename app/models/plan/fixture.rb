class Plan
  
  # there are list of all plans
  create :id => 1, :name => "Trial", :price => BigDecimal.new("0")
  create :id => 2, :name => "Free", :price => BigDecimal.new("0")
  create :id => 3, :name => "UnlimitedTrial", :price => BigDecimal.new("0")
  create :id => 4, :name => "Single", :price => BigDecimal.new("3")
  create :id => 5, :name => "Professional", :price => BigDecimal.new("15")
  
  
end