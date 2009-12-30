class PlansController < ApplicationController
  before_filter :authenticate_owner!
  
  def professional
    @card = CreditCard.new params[:card]
    if request.post? && @card.valid?
      current_user.set_professional_plan(@card)
      redirect_to preferences_path
    end
  end

  def free
    if request.post?
      sites = Site.find(params[:sites]) 
      pages = Page.find(params[:pages])
      if current_user.set_free_plan(sites, pages)
        redirect_to preferences_path
      end
    end
  end
end
