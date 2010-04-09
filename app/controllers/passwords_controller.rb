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

  def edit
    @user = User.new
    @user.reset_password_token = params[:reset_password_token]
  end

  def update
    @user = User.find_by_reset_password_token params[:user][:reset_password_token]
    if !@user
      render_message 'Invalid confirmation token'
    else
      @user.require_password
      @user.reset_password!(params[:user][:password], params[:user][:password_confirmation])

      if @user.errors.empty?
        flash[:success] = I18n.t("devise.passwords.updated")
        sign_in(:user, @user)
        send_redirect user_root_path
      else
        render_errors :user => @user
      end
    end
  end
end
