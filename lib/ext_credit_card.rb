class ExtCreditCard < ActiveMerchant::Billing::CreditCard
  attr_reader :expiration
  attr_accessor :zip

  def expiration=(exp)
    @expiration = exp
    if @expiration.blank? || !expiration_format_valid?
      @month, @year = nil, nil
    else
      m, y = @expiration.split '/'
      @month, @year = m.to_i, y.to_i
    end
  end

  def validate
    validate_expiration
    super

    e = errors.on(:month)
    errors.add(:expiration, e) if e

    e = errors.on(:year)
    errors.add(:expiration, e) if e

    errors.add(:zip, 'is required') if zip.blank?
  end

  private

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
