class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.create params[:user]
    if @user.save
      flash[:notice] = t('devise.confirmations.send_instructions')
      redirect_to root_path
    else
      render :action => :new
    end
  end
end
