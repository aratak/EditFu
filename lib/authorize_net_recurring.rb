class AuthorizeNetRecurring
  def self.create(gateway, amount, owner, card)
    response = gateway.recurring(amount, card, 
      :interval => { :unit => :months, :length => 1 },
      :duration => { :start_date => owner.billing_date, :occurrences => 9999 },
      :billing_address => { 
        :first_name => card.first_name, :last_name => card.last_name, :zip => card.zip
      }
    )
    owner.subscription_id = response.params['subscription_id']
    raise PaymentSystemError, build_message(response) unless owner.subscription_id
  end

  def self.cancel(gateway, owner)
    if owner.subscription_id
      response = gateway.cancel_recurring(owner.subscription_id)
      raise PaymentSystemError, response.message unless response.success?
      owner.subscription_id = nil
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
