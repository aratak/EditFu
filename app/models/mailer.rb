class Mailer < ActionMailer::Base
  def signup(user)
    setup   user
    subject "Welcome to EditFu. Now meet the ninjas."
  end

  def editor_invitation(user)
    setup   user
    subject "Content editor invitation."
  end

  def reset_password(user)
    setup   user
    subject      "Reset edit-fu password"
  end

  private

  def setup(user)
    from         "edit.fu.cms@gmail.com"
    recipients   user.email
    content_type 'text/html'
    body         :user => user
  end
end
