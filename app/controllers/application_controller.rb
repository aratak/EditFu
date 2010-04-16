# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :redirect_to_subdomain if RAILS_ENV != 'test'
  layout nil
  
  include PlanRestrictions

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def user_root_path
    if current_user.admin?
      admin_owners_path
    else
      sites_path
    end
  end

  protected

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

  def redirect_to_subdomain
    if can_redirect?
      host = desired_host
      if request.host != host
        redirect_to request.protocol + host + request.port_string + request.request_uri
      end
    end
  end

  def desired_host
    if !user_signed_in?
      BASE_DOMAIN
    else
      current_user.company_domain
    end
  end

  def authenticate_user_type!(type)
    authenticate_user!

    if user_signed_in? && !current_user.kind_of?(type)
      redirect_to root_path
    end
  end
  
  def can_redirect?
    request.get? && !request.xhr?
  end
end
