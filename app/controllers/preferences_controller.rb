class PreferencesController < ApplicationController
  layout 'application'
  
  before_filter :authenticate_user!
  before_filter :set_preferences

  def show
  end

  def edit
  end

  def update
    @owner.update_attributes(params[:preferences][:owner])
    plan = params[:preferences][:owner][:plan]
    @card = ExtCreditCard.new params[:preferences][:card]

    if plan == 'professional' && (plan != @owner.plan || !@card.number.blank?)
      @card.valid?
      if @owner.errors.empty? && @card.errors.empty?
        @owner.set_professional_plan @card
      end
    end

    unless @owner.errors.empty? && @card.errors.empty?
      render_errors :preferences_owner => @owner, :preferences_card => @card
    end
  end

  private

  def set_preferences
    @owner = current_user
    @card = ExtCreditCard.new
  end
end
