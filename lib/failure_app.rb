class FailureApp < Devise::FailureApp
  def respond!
    if !request || !request.xhr?
      super
    else
      redirect_path = "/users/sign_in"
      headers = {}
      headers["X-Location"] = redirect_path
      headers["Content-Type"] = 'text/plain'
      [200, headers, []]
    end
  end
end
