class PaymentSystem
  # def self.authorized?(card)
  #   gateway.authorize(PAYMENT_RECURRING_AMOUNT, card).success?
  # end

  def self.recurring(card)
    recurring_gateway.create(gateway, card.price, card)
  end

  def self.update_recurring(card)
    recurring_gateway.update(gateway, card)
  end

  def self.cancel_recurring(card)
    recurring_gateway.cancel(gateway, card)
  end

  private

  def self.recurring_gateway
    Kernel.const_get("#{PAYMENT_GATEWAY_NAME}_recurring".camelize)
  end

  def self.gateway
    ActiveMerchant::Billing::Base.gateway(PAYMENT_GATEWAY_NAME).
      new(PAYMENT_GATEWAY_OPTS)
  end
end
