class Mailer < ActionMailer::Base
  def owner_confirmation_instructions(owner)
    subject      "Account confirmation"
    from         "edit.fu.cms@gmail.com"
    recipients   owner.email
    content_type 'text/html'
    body         :owner => owner
  end

  def editor_confirmation_instructions(editor)
    subject      "Account confirmation"
    from         "edit.fu.cms@gmail.com"
    recipients   editor.email
    content_type 'text/html'
    body         :editor => editor
  end
end
