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
    translate_messages

    e = errors.on(:month)
    errors.add(:expiration, e) if e

    e = errors.on(:year)
    errors.add(:expiration, e) if e

    errors.add(:zip, blank_message) if zip.blank?
  end
  
  def invalid?
    !valid?
  end

  private

  def validate_expiration
    if @expiration.blank?
      errors.add :expiration, blank_message
    elsif !expiration_format_valid?
      errors.add :expiration, "is invalid"
    end
  end

  def expiration_format_valid?
    @expiration.match /\d\d?\/\d\d\d\d/
  end

  def translate_messages
    errors.each do |k, v|
      v.each_index do |i|
        if v[i] == "cannot be empty"
          v[i] = blank_message
        end
      end
    end
  end

  def blank_message
    I18n.t('activerecord.errors.messages.blank')
  end
end
