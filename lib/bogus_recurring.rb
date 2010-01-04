class BogusRecurring
  @@response = ActiveMerchant::Billing::Response.new(true, nil)

  def self.create(gateway, amount, owner, card)
    @@response
  end

  def self.cancel(gateway, owner)
    @@response
  end
end
