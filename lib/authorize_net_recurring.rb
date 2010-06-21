class AuthorizeNetRecurring
  def self.create(gateway, amount, owner, card)
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

  def self.update(gateway, owner, card)
    response = gateway.update_recurring(
      :subscription_id => card.subscription_id,
      :credit_card => card.credit_card,
      :billing_address => { 
        :first_name => card.first_name, :last_name => card.last_name, :zip => card.zip
      }
    )
    raise PaymentSystemError, build_message(response) unless response.success?
  end

  def self.cancel(gateway, owner)
    if owner.card.subscription_id
      response = gateway.cancel_recurring(owner.card.subscription_id)
      raise PaymentSystemError, response.message unless response.success?
      owner.card.subscription_id = nil
    end
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
