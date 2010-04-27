class OwnerConfirmationsController < ApplicationController
  def show
    @owner = Owner.confirm!(:confirmation_token => params[:confirmation_token])

    if @owner.errors.empty?
      flash[:success] = 'Account is confirmed.'
      sign_in_and_redirect :user, @owner
    else
      flash[:failure] = 'Invalid confirmation token.'
      redirect_to new_user_session_path
    end
  end
end
