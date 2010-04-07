class OwnerPreferencesController < ApplicationController
  before_filter :authenticate_owner!
  before_filter :set_preferences

  def show
  end

  def update
    password = params[:preferences][:owner][:password]
    unless password.blank?
      @owner.password = password
      @owner.password_confirmation = password
      @owner.save!
    end

    @owner.update_attributes(params[:preferences][:owner])
    @plan = params[:preferences][:owner][:plan]
    @card = ExtCreditCard.new params[:preferences][:card]

    @plan_changed = @plan != @owner.plan
    if @plan == 'professional' && (@plan_changed || !@card.number.blank?)
      @card.valid?
      if @owner.errors.empty? && @card.errors.empty?
        begin
          if @plan_changed
            @owner.set_professional_plan @card
          else
            @owner.set_card @card
          end
        rescue PaymentSystemError => e
          render_message e.message
        end
      end
    end

    unless @owner.errors.empty? && @card.errors.empty?
      render_errors :preferences_owner => @owner, :preferences_card => @card
    end
  end

  def downgrade
    sites = Site.find params[:sites]
    pages = Page.find params[:pages]
    @owner.set_free_plan sites, pages
  end

  private

  def set_preferences
    @owner = current_user
    @card = ExtCreditCard.new
  end
end
