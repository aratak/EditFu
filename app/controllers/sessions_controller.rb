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
    sign_out(:user) and reset_session if signed_in?(:user)

    if authenticate(:user)
      flash[:success] = I18n.t("devise.sessions.signed_in", :user_name => current_user.user_name)
      location = stored_location_for(:user) || current_user.last_requested_uri || user_root_path
      store_uri_to_cookie(location)
      if location =~ /^\/(sites|editors).*/
        redirect_to :controller => "#{$1}" 
      else
        redirect_to user_root_path
      end
    else
      message = warden.message || :invalid
      flash.now[:failure] = I18n.t("devise.sessions.#{message}")
      @user = User.new params[:user]
      render :new
    end
  end

  def destroy
    flash[:success] = I18n.t("devise.sessions.signed_out") if signed_in?(:user)
    sign_out_and_redirect(:user) and reset_session
  end
end
