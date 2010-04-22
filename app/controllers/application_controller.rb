# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout nil
  
  filter_parameter_logging 'password', 'card'

  include PlanRestrictions

  def user_root_path
    if current_user.admin?
      admin_owners_path
    else
      sites_path
    end
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
    user_signed_in? && request.host =~ /(.*)\.#{BASE_DOMAIN}$/ && 
      current_user.subdomain != $1
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

    if correct_subdomain! && user_signed_in? && !current_user.kind_of?(type)
      redirect_to root_path
    end
  end
  
  def can_redirect?
    RAILS_ENV != 'test' && request.get? && !request.xhr?
  end

  def company_url
    request.protocol + current_user.company_domain + request.port_string + request.request_uri
  end

  def correct_subdomain!
    if can_redirect?
      if wrong_subdomain?
        redirect_to root_path
        return false
      elsif request.host == BASE_DOMAIN 
        if user_signed_in?
          redirect_to company_url
          return false
        end
      end
    end

    true
  end
end
