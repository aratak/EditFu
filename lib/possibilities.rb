module Possibilities

  def self.included m
    return unless m < ActionController::Base
    m.before_filter :check_trial_period, :check_add_page, :check_add_site, :check_add_editor
  end


  def check_trial_period
    deny_popup "shared/trial_period_expired",
               :if => :"trial_period_expired?", 
               :for => ["pages/show", "pages/update", "pages/new", "pages/create", "sites/new", "sites/create", "editors/new", "editors/create"]
  end
  
  def check_add_editor
    deny_popup "shared/upgrade",
               :if => :"can_add_site?", 
               :for => ["editors/new", "editors/create"]
  end

  def check_add_page
    deny_popup "shared/upgrade",
               :if => :"can_add_page?", 
               :for => ["pages/show", "pages/update", "pages/new", "pages/create"]
  end
  
  def check_add_site
    deny_popup "shared/upgrade",
               :if => :"can_add_site?", 
               :for => ["pages/show", "pages/update", "pages/new", "pages/create"]
  end

  private
  
  def deny_popup deny_partial, params ={} 
    deny_condition = params[:if]
    actions_list = params[:for]
    
    return true unless actions_list.include?(current_action)
    
    if current_user && current_user.send(deny_condition.to_sym)
      respond_to do |format|
        format.html {
          @content_for_popup = render_to_string(:partial => deny_partial) 
        }
        format.js  { 
          render :update do |page|
            page.replace_html 'popup', :partial => deny_partial
            page.show 'popup-system'            
          end
        }
      end
    end
  end

  def current_action
    "#{controller_name}/#{action_name}"
  end
  
end