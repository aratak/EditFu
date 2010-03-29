class SimplePreferencesController < ApplicationController
  before_filter :authenticate_user!

  def show
  end

  def update
    current_user.user_name = params[:preferences][:user_name]
    current_user.email = params[:preferences][:email]
    if params[:preferences][:password]
      current_user.password = params[:preferences][:password]
      current_user.password_confirmation = params[:preferences][:password]
    end

    unless current_user.save
      render_errors :preferences => current_user
    end
  end
end
