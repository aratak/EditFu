class PasswordsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.send_reset_password_instructions(params[:user])

    if @user.errors.empty?
      flash[:success] = I18n.t("devise.passwords.send_instructions")
      redirect_to new_session_path(:user)
    else
      flash.now[:failure] = @user.errors[:email]
      render :new
    end
  end
end
