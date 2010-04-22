class OwnerPreferencesController < ApplicationController
  before_filter :authenticate_owner!
  before_filter :set_preferences

  def show
  end

  def update
    @owner.require_current_password
    @owner.update_attributes(params[:preferences][:owner])
    @message = ['preferences.updated']

    @plan = params[:preferences][:owner][:plan]
    @card = ExtCreditCard.new params[:preferences][:card]

    @plan_changed = @plan != @owner.plan
    if @plan == 'professional' && (@plan_changed || !@card.number.blank?)
      @card.valid?
      if @owner.errors.empty? && @card.errors.empty?
        begin
          if @plan_changed
            @message = ['plan.upgraded', {:plan_was => @owner.plan.capitalize}]
            @owner.set_professional_plan @card
          else
            @owner.set_card @card
          end
        rescue PaymentSystemError
          render_message I18n.t('plan.payment_error', 
            :contact_us => MessageKeywords.contact_us('contact us'), 
            :support => MessageKeywords.support_email)
        end
      end
    end

    unless @owner.errors.empty? && @card.errors.empty?
      render_errors :preferences_owner => @owner, :preferences_card => @card
    end
  end

  def downgrade
    sites = pages = []
    sites = Site.find(params[:sites]) if params[:sites]
    pages = Page.find(params[:pages]) if params[:pages]
    @owner.set_free_plan sites, pages
  end

  private

  def set_preferences
    @owner = current_user
    @card = ExtCreditCard.new
  end
end
