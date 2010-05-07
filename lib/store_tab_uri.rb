module StoreTabUri
  COOKIE_SUFFIX = "_uri" 

  def self.included m
    return unless m < ActionController::Base
    m.after_filter :store_uri_to_cookie
  end

  def redirect_from_cookie cookie_name=nil
    session_name = session_name || "#{controller_name}#{COOKIE_SUFFIX}"
    
    redirect_to(session[session_name.to_s]) and return false if should_be_redirected?(session_name)
    return true
  end
  
  def store_uri_to_cookie
    return false unless request.get? && !request.xhr?
    uri = request.request_uri 

    if uri =~ /^\/(sites|editors).*/
      session["#{$1}#{COOKIE_SUFFIX}"] = uri
    end
  end
  
  private

  def should_be_redirected? session_name
    request.get? && !request.xhr? && session[session_name].to_s.any? && !(session[session_name] == request.request_uri)
  end

end
