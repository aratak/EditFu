module PlanRestrictions
  ALL_ACTIONS = ["pages/show", "pages/update", "pages/new", "pages/create", 
                 "sites/new", "sites/create", "editors/new", "editors/create"]
  PERMISSIONS = [:check_trial_period, :check_hold, :check_add_page, :check_add_site, :check_add_editor, :check_credit_card]

  def self.included m
    return unless m < ActionController::Base
    m.before_filter :check_permissions
  end

  protected

  def check_permissions
    PERMISSIONS.all? do |perm|
      self.send(perm)
    end
  end

  def check_credit_card
    show_popup "shared/credit_card",
               :if => :"credit_card_expired?",
               :for => ALL_ACTIONS
  end

  def check_hold
    show_popup "shared/hold",
               :if => :"hold?", 
               :for => ALL_ACTIONS
  end

  def check_trial_period
    show_popup "shared/trial_period_expired",
               :if => :"trial_period_expired?",
               :for => ALL_ACTIONS
  end
  
  def check_add_page
    show_popup "shared/upgrade",
               :unless => :"can_add_page?", 
               :for => ["pages/new", "pages/create"]
  end

  def check_add_editor
    show_popup "shared/upgrade",
               :unless => :"can_add_editor?", 
               :for => ["editors/new", "editors/create"]
  end

  def check_add_site
    show_popup "shared/upgrade",
               :unless => :"can_add_site?", 
               :for => ["sites/new", "sites/create"]
  end

  private
  
  def show_popup(partial, params = {})
    return true unless user_signed_in?
    return true unless params[:for].include?(current_action)

    condition = deny_condition(params)
    if condition
      respond_to do |format|
        format.html {
          @content_for_popup = render_to_string(:partial => partial) 
        }
        format.js  { 
          render :update do |page|
            show_popup page, :partial => partial
          end
        }
      end
    end
    !condition
  end

  def deny_condition(params = {})
    result = false
    if params[:if]
      result = current_user.send(params[:if])
    elsif params[:unless]
      result = !current_user.send(params[:unless])
    end
    result
  end

  def current_action
    "#{controller_name}/#{action_name}"
  end
end
