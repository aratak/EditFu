class PaymentSystem
  def self.authorized?(card)
    gateway.authorize(PAYMENT_RECURRING_AMOUNT, card).success?
  end

  def self.recurring(owner, card)
    recurring_gateway.create(gateway, PAYMENT_RECURRING_AMOUNT, owner, card)
  end

  def self.cancel_recurring(owner)
    recurring_gateway.cancel(gateway, owner)
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
