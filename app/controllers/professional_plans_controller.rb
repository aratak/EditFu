class ProfessionalPlansController < ApplicationController
  before_filter :authenticate_owner!
  
  def show
    @card = ActiveMerchant::Billing::CreditCard.new
  end
  
  def create
    @card = ActiveMerchant::Billing::CreditCard.new params[:card]
    if @card.valid?
      current_user.set_professional_plan(@card)
      redirect_to preferences_path
    else
      render :action => :show
    end
  end
end
