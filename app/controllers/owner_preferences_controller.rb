class OwnerPreferencesController < ApplicationController
  layout 'member'
  before_filter :authenticate_owner!
  before_filter :set_preferences

  def show
    @show_account = 'active'
  end

  def update
    @owner.require_current_password
    @owner.attributes = params[:owner]
    
    if @owner.save
      flash[:notice] = 'Preferences were updated successfully.' 
      redirect_to plain_sites_url
    else
      flash[:error] = @owner.errors.full_messages.first
      @show_account = 'active'
      render :show
    end

  end
  
  def billing_update
    @owner.card_must_be_present = true
    @owner.set_plan(params[:owner][:plan_id])
    params[:owner].delete(:subscriptions_attributes) # deny for current_user
    @owner.attributes = params[:owner]

    if @owner.save
      flash[:notice] = 'Preferences were updated successfully.' 
      redirect_to plain_sites_url
    else
      @show_billing = 'active'
      card_errors = @owner.card.nil? ? [] : @owner.card.errors.full_messages 
      flash[:error] = (@owner.errors.full_messages + card_errors).uniq.first
      render :show
    end
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
  end
end

#####################################################
# 
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
#         @owner.set_plan('professional', params)
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