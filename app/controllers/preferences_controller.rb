class PreferencesController < ApplicationController
  layout 'application'
  
  before_filter :authenticate_user!
  before_filter :set_preferences

  def show
  end

  def edit
  end

  def update
    if @preferences.update_attributes(params[:preferences])
      redirect_to preferences_path
    else
      render :edit
    end
  end

  private

  def set_preferences
    @preferences = current_user
  end
end
