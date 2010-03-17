class ExtCreditCard < ActiveMerchant::Billing::CreditCard
  attr_accessor :expiration

  def validate
    validate_expiration
    super

    e = errors.on(:month)
    errors.add(:expiration, e) if e

    e = errors.on(:year)
    errors.add(:expiration, e) if e
  end

  private

  def before_validate
    if !@expiration.blank? && expiration_format_valid?
      @month, @year = @expiration.split '/'
    end
    super
  end

  def validate_expiration
    if @expiration.blank?
      errors.add :expiration, "cannot be empty"
    elsif !expiration_format_valid?
      errors.add :expiration, "is invalid"
    end
  end

  def expiration_format_valid?
    @expiration.match /\d\d?\/\d\d\d\d/
  end
end
