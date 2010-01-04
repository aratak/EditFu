class CreditCard < ActiveMerchant::Billing::CreditCard
  def validate
    super
    if errors.empty? && !PaymentSystem.authorized?(self)
      errors.add_to_base I18n.t('credit_card.authorize')
    end
  end
end
