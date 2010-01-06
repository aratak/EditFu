class AuthorizeNetRecurring
  def self.create(gateway, amount, owner, card)
    response = gateway.recurring(amount, card, 
      :interval => { :unit => :months, :length => 1 },
      :duration => { :start_date => Date.today.next_month , :occurrences => 9999 },
      :billing_address => { 
        :first_name => card.first_name, :last_name => card.last_name 
      }
    )
    owner.subscription_id = response.params['subscription_id']
    raise PaymentSystemError, response.message unless owner.subscription_id
  end

  def self.cancel(gateway, owner)
    if owner.subscription_id
      response = gateway.cancel_recurring(owner.subscription_id)
      raise PaymentSystemError, response.message unless response.success?
      owner.subscription_id = nil
    end
  end
end
