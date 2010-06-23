class BogusRecurring
  def self.create(gateway, amount, card)
    card.subscription_id = rand(10000000).to_s
  end

  def self.update(gateway, card)
  end

  def self.cancel(gateway, card)
  end
end
