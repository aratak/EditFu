class AuthorizeNetRecurring
  def self.create(gateway, amount, card)
    owner = card.owner
    response = gateway.recurring(amount, card.credit_card, 
      :interval => { :unit => :months, :length => 1 },
      :duration => { :start_date => owner.next_billing_date.strftime('%Y-%m-%d'), :occurrences => 9999 },
      :billing_address => { 
        :first_name => card.first_name, :last_name => card.last_name, :zip => card.zip
      }
    )

    card.subscription_id = response.params['subscription_id']
    raise PaymentSystemError, build_message(response) unless card.subscription_id
  end

  def self.update(gateway, card)
    response = gateway.update_recurring(
      :subscription_id => card.subscription_id,
      :credit_card => card.credit_card,
      :billing_address => { 
        :first_name => card.first_name, :last_name => card.last_name, :zip => card.zip
      }
    )

    raise PaymentSystemError, build_message(response) unless response.success?
  end

  def self.cancel(gateway, card)
    return false if card.subscription_id.nil?

    response = gateway.cancel_recurring(card.subscription_id)
    raise PaymentSystemError, response.message unless response.success?
    card.subscription_id = nil
    true
  end

  private

  def self.build_message(response)
    if response.params[:response_reason_code] == 'E00012'
      'A duplicate subscription already exists.'
    else
      response.message
    end
  end
end
