class PreferencesController < ApplicationController
  layout 'application'
  
  before_filter :authenticate_owner!
  before_filter :set_preferences

  def show
  end

  def edit
  end

  def update
    @owner.update_attributes(params[:preferences][:owner])
    plan = params[:preferences][:owner][:plan]
    @card = ExtCreditCard.new params[:preferences][:card]

    plan_changed = plan != @owner.plan
    if plan == 'professional' && (plan_changed || !@card.number.blank?)
      @card.valid?
      if @owner.errors.empty? && @card.errors.empty?
        if plan_changed
          @owner.set_professional_plan @card
        else
          @owner.set_card @card
        end
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
