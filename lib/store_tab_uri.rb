module StoreTabUri
  COOKIE_SUFFIX = "_uri" 

  def self.included m
    return unless m < ActionController::Base
    m.after_filter :store_uri_to_cookie
  end

  def redirect_from_cookie cookie_name=nil
    cookie_name = cookie_name || "#{controller_name}#{COOKIE_SUFFIX}"
    
    redirect_to(cookies[cookie_name.to_s]) and return false if should_be_redirected?(cookie_name)
    return true
  end
  
  def store_uri_to_cookie
    return false unless request.get? && !request.xhr?
    uri = request.request_uri 

    if uri =~ /^\/(sites|editors).*/
      cookies["#{$1}#{COOKIE_SUFFIX}"] = uri
    end
  end

  private

  def should_be_redirected? cookie_name
    request.get? && !request.xhr? && cookies[cookie_name].to_s.any? && !(cookies[cookie_name] == request.request_uri)
  end

end
