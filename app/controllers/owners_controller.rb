class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    @user.require_password
    if @user.save
      flash[:notice] = t('devise.confirmations.send_instructions')
      redirect_to root_path
    else
      render :new
    end
  end
end
