class OwnersController < ApplicationController
  before_filter :authenticate_owner!, :only => :destroy
  layout 'public'

  # GET /owners/new
  def new
    @owner = Owner.new
  end

  # POST /owners
  def create
    @owner = Owner.new params[:owner]
    @owner.require_password
    if @owner.save
      flash[:success] = t('devise.confirmations.send_instructions')
      redirect_to root_path
    else
      render :new
    end
  end

  # DELETE /owner
  def destroy
    current_user.destroy

    flash[:success] = "Your acccount was canceled."
    redirect_to root_url
  end
end
