class SessionsController < ApplicationController
  layout 'public'
  before_filter :load_company_logo

  def new
    Devise::FLASH_MESSAGES.each do |message|
      if params.try(:[], message) == "true"
        flash.now[:error] = I18n.t("devise.sessions.#{message}")
      elsif wrong_subdomain?
        flash.now[:error] = I18n.t('devise.sessions.wrong_subdomain', 
          :company => MessageKeywords.company_domain(current_user),
          :editfu => MessageKeywords.editfu)
      end
    end
    @user = User.new
  end

  def create
    sign_out(:user) if signed_in?(:user)

    if authenticate(:user)
      @user = User.find_by_email(params[:user][:email])
      flash[:success] = I18n.t("devise.sessions.signed_in", :user_name => @user.user_name)
      location = stored_location_for(:user) || 
        current_user.last_requested_uri || user_root_path
      redirect_to location
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
