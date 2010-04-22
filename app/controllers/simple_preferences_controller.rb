class SimplePreferencesController < ApplicationController
  before_filter :authenticate_all!

  def show
  end

  def update
    current_user.require_current_password
    unless current_user.update_attributes(params[:preferences])
      render_errors :preferences => current_user
    end
  end
end
