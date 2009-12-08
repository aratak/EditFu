class OwnersController < ApplicationController
  def new
    @owner = Owner.new
  end

  def create
    @owner = Owner.new params[:owner]
    @owner.require_password
    if @owner.save
      flash[:notice] = t('devise.confirmations.send_instructions')
      redirect_to root_path
    else
      render :new
    end
  end
end
