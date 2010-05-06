# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout nil
  
  filter_parameter_logging 'password', 'card'

  include PlanRestrictions
  include StoreTabUri

  def user_root_path
    if current_user.admin?
      path = admin_owners_path
    else
      path = sites_path
    end
    RAILS_ENV == 'test' ? path: company_url(path)
  end

  def request_subdomain
    request.host =~ /(.*)\.#{BASE_DOMAIN}$/
    $1 != 'www' ? $1 : nil
  end

  protected

  def authenticate_all!
    authenticate_user_type!(User)
  end

  def authenticate_owner!
    authenticate_user_type!(Owner)
  end

  def authenticate_editor!
    authenticate_user_type!(Editor)
  end

  def authenticate_admin!
    authenticate_user_type!(Admin)
  end

  def send_redirect(path)
    head :'X-Location' => path
  end

  def wrong_subdomain?
    rs = request_subdomain
    user_signed_in? && rs.present? && current_user.subdomain != rs
  end

  def load_company_logo
    subdomain = request_subdomain
    if subdomain.present?
      @company_owner = Owner.find_by_domain_name subdomain
      @company_logo = @company_owner.identity if @company_owner
    end
  end

  private

  def render_message(message)
    render :update do |page|
      show_message page, 'error', message
    end
  end

  def render_errors(models)
    render :update do |page|
      show_error_messages page, models
    end
  end

  def authenticate_user_type!(type)
    authenticate_user!

    if correct_subdomain! && user_signed_in?
      if !current_user.kind_of?(type)
        flash[:warning] = I18n.t('devise.sessions.permissions')
        redirect_to new_user_session_path
      elsif can_redirect?
        current_user.last_requested_uri = request.request_uri
        current_user.save
      end
    end
  end
  
  def can_redirect?
    RAILS_ENV != 'test' && request.get? && !request.xhr?
  end
  
  def company_url(path)
    request.protocol + current_user.company_domain + request.port_string + path
  end

  def correct_subdomain!
    if can_redirect?
      if wrong_subdomain?
        redirect_to new_user_session_path
        return false
      elsif request.host == BASE_DOMAIN 
        if user_signed_in?
          redirect_to company_url(request.request_uri)
          return false
        end
      end
    end

    true
  end
end
