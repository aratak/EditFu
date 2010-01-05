class PlansController < ApplicationController
  before_filter :authenticate_owner!
  
  def professional
    @card = CreditCard.new params[:card]
    if request.post? && @card.valid?
      begin
        current_user.set_professional_plan(@card)
        redirect_to preferences_path
      rescue PaymentSystemError => e
        flash.now[:failure] = e.message
      end
    end
  end

  def free
    if request.post?
      sites = Site.all(params[:sites]) 
      pages = Page.all(params[:pages])
      if current_user.set_free_plan(sites, pages)
        redirect_to preferences_path
      end
    end
  end
end
