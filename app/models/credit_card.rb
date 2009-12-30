class CreditCard < ActiveMerchant::Billing::CreditCard
  cattr_accessor :login, :password, :recurring_amount

  def validate
    super
    if errors.empty? && !gateway.authorize(recurring_amount, self).success?
      errors.add_to_base I18n.t('credit_card.authorize')
    end
  end

  private 

  def gateway
    ActiveMerchant::Billing::AuthorizeNetGateway.new(
      :login    => CreditCard.login,
      :password => CreditCard.password
    )
  end
end
