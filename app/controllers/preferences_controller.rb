class PreferencesController < ApplicationController
  layout 'application'
  
  before_filter :authenticate_user!
  before_filter :set_preferences

  def show
  end

  def edit
  end

  def update
    plan = params[:preferences][:owner][:plan]
    if @owner.update_attributes(params[:preferences][:owner])
      render :json => @owner.errors
    elsif @owner.plan != plan
      if plan == 'free'
        @owner.set_free_plan
      end
    end
  end

  private

  def set_preferences
    @owner = current_user
    @card = CreditCard.new
  end
end
