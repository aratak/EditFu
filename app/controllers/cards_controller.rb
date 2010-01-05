class CardsController < ApplicationController
  def edit
    @card = CreditCard.new
  end

  def update
    @card = CreditCard.new params[:card]
    if @card.valid?
      begin
        current_user.set_card(@card)
        redirect_to preferences_path
        return
      rescue PaymentSystemError => e
        flash.now[:failure] = e.message
      end
    end
    render :action => :new
  end
end
