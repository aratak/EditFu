class OwnerPreferencesController < ApplicationController
  before_filter :authenticate_owner!
  before_filter :set_preferences

  def show
  end

  def update
    @owner.require_current_password
    @owner.update_attributes(params[:owner])
    render_errors(:owner => @owner) unless @owner.save
    @message = ['preferences.updated']
  end
  
  def billing_update
    # @owner.build_card
    @owner.set_plan(params[:owner][:plan_id])
    @owner.update_attributes(params[:owner])
    p "="*50
    p @owner
    p @owner.card
    p "^"*50
    render_errors(:owner => @owner) unless @owner.save

    # begin
    #   @plan_changed = @owner.set_plan(params[:owner][:plan_id], params) if params[:preferences][:owner][:plan_id]
    #   @owner.build_card(params[:preferences][:card]) if params[:preferences][:card]
    # rescue PaymentSystemError
    #   render_message I18n.t('plan.payment_error', 
    #                         :contact_us => MessageKeywords.contact_us('contact us'), 
    #                         :support => MessageKeywords.support_email)
    # end
    # unless @owner.save
    #   @message = [I18n.t('plan.upgraded', :plan_was => @owner.plan_was.name)] if @plan_changed
    #   @message = [I18n.t('credit_card.updated')] if @card
    # else
    #   render_errors :owner => @owner #, :preferences_card => @card
    # end
  end

  def downgrade
    @owner.set_plan(Plan::FREE, params)
  end
  
  def identity
    current_user.update_attribute :identity, nil
  end

  private

  def set_preferences
    @owner = current_user
    @card = ExtCreditCard.new
  end
end

# @owner.require_current_password
# @owner.update_attributes(params[:preferences][:owner])
# @message = ['preferences.updated']
# 
# @plan = params[:preferences][:owner][:plan]
# @card = ExtCreditCard.new params[:preferences][:card]
#
# @plan_changed = @plan != @owner.plan
# if @plan == 'professional' && (@owner.plan_changed? || !@card.number.blank?)
#   @card.valid?
#   if @owner.errors.empty? && @card.errors.empty?
#     begin
#       if @owner.plan_changed?
#         @owner.set_plan(Plan::PROFESSIONAL, params)
#         @message = ['plan.upgraded', {:plan_was => @owner.plan_was.name}]
#       else
#         @owner.set_card @card
#       end
#     rescue PaymentSystemError
#       render_message I18n.t('plan.payment_error', 
#         :contact_us => MessageKeywords.contact_us('contact us'), 
#         :support => MessageKeywords.support_email)
#     end
#   end
# end
# 
# unless @owner.errors.empty? && @card.errors.empty?
#   render_errors :preferences_owner => @owner, :preferences_card => @card
# end