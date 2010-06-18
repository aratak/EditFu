class Owner
  
  def set_card(card)
    logger.warn("the method 'trial_period_end' will be deplicated")
    self.card = card
    self.card
  end

  def destroy_card
    card.destroy unless card.nil?
  end
  
  def card_present?
    !card.nil?
  end

  # def subscription_id
  #   card.subscription_id unless card.nil?
  # end
  # 
  # def subscription_id= val
  #   card.subscription_id = val unless card.nil?
  # end


end