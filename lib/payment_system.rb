class PaymentSystem
  cattr_accessor :gateway_name, :gateway_opts, :recurring_amount

  def self.authorized?(card)
    gateway.authorize(recurring_amount, card).success?
  end

  def self.recurring(owner, card)
    check_response(
      recurring_gateway.create(gateway, recurring_amount, owner, card)
    )
  end

  def self.cancel_recurring(owner)
    check_response(
      recurring_gateway.cancel(gateway, owner)
    )
  end

  private

  def self.check_response(response)
    raise response.message unless response.success?
  end

  def self.recurring_gateway
    Kernel.const_get("#{self.gateway_name}_recurring".camelize)
  end

  def self.gateway
    ActiveMerchant::Billing::Base.gateway(gateway_name).new(gateway_opts)
  end
end
