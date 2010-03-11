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
  
  def check_add_page
    deny_popup "shared/upgrade",
               :unless => :"can_add_page?", 
               :for => ["pages/show", "pages/update", "pages/new", "pages/create"]
  end

  def check_add_editor
    deny_popup "shared/upgrade",
               :unless => :"can_add_editor?", 
               :for => ["editors/new", "editors/create"]
  end

  def check_add_site
    deny_popup "shared/upgrade",
               :unless => :"can_add_site?", 
               :for => ["sites/new", "sites/create"]
  end

  private
  
  def deny_popup deny_partial, params ={} 
    return true unless current_user
    return true unless params[:for].to_a.include?(current_action)

    if deny_condition(params)
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
  
  def deny_condition params = {}
    unless params[:if].nil?
      current_user.send(params[:if].to_sym) 
    else
      !current_user.send(params[:unless].to_sym)
    end
  end

  def current_action
    "#{controller_name}/#{action_name}"
  end
  
end