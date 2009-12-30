class PlansController < ApplicationController
  before_filter :authenticate_owner!
  
  def professional
    @card = ActiveMerchant::Billing::CreditCard.new params[:card]
    if request.post? && @card.valid?
      current_user.set_professional_plan(@card)
      redirect_to preferences_path
    end
  end

  def free
    if request.post? && current_user.set_free_plan(Site.find(params[:sites]), 
                                           Page.find(params[:pages]))
      redirect_to preferences_path
    end
  end
end
