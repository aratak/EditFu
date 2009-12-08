class OwnerConfirmationsController < ApplicationController
  def show
    @owner = Owner.confirm!(:confirmation_token => params[:confirmation_token])

    if @owner.errors.empty?
      flash[:notice] = 'Account is confirmed.'
      sign_in_and_redirect @owner
    else
      flash[:notice] = 'Invalid confirmation token.'
      redirect_to root_path
    end
  end
end
