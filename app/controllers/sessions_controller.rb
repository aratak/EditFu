class SessionsController < ApplicationController
  layout 'public'

  def new
    Devise::FLASH_MESSAGES.each do |message|
      if params.try(:[], message) == "true"
        flash.now[:failure] = I18n.t("devise.sessions.#{message}")
      end
    end
    @user = User.new
  end

  def create
    sign_out(:user) if signed_in?(:user)

    if authenticate(:user)
      @user = User.find_by_email(params[:user][:email])
      flash[:success] = I18n.t("devise.sessions.signed_in", :user_name => @user.user_name)
      sign_in_and_redirect(:user)
    else
      message = warden.message || :invalid
      flash.now[:failure] = I18n.t("devise.sessions.#{message}")
      @user = User.new params[:user]
      render :new
    end
  end

  def destroy
    flash[:success] = I18n.t("devise.sessions.signed_out") if signed_in?(:user)
    sign_out_and_redirect(:user)
  end
end
