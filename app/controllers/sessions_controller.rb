class SessionsController < ApplicationController
  layout 'public'
  before_filter :load_company_logo
  before_filter :redirect_from_error, :only => [:new]
  #before_filter :ssl_required, :only => [:new]

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
    @title = 'EditFu - Content Management System'
  end

  def create
    sign_out(:user) and reset_session if signed_in?(:user)

    if authenticate(:user)
      flash[:success] = I18n.t("devise.sessions.signed_in", :user_name => current_user.user_name)
      redirect_to user_root_path
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
  
  private
  
  def redirect_from_error
    return true unless user_signed_in? && params[:redirect]
    # return true if params[:redirect] == ""
    
    if current_user.kind_of?(Admin) 
      redirect_to(owners_path) and return(false)
    else
      redirect_to(sites_path) and return(false)
    end
    
  end

  def ssl_required
    return if Rails.env.development? || request.ssl?
    redirect_to('https://' + request.host + request.request_uri)
  end

end
