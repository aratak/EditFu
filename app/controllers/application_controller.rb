# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  ConfirmationsController.class_eval do
    before_filter :redirect_editors, :only => [:create, :show]

    private

    def redirect_editors
      user = User.find_by_confirmation_token(params[:confirmation_token])
      if user && user.editor?
        redirect_to edit_editor_confirmation_path(
          :confirmation_token => params[:confirmation_token]
        )
      end
    end
  end
end
