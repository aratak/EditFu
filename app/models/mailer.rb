class Mailer < ActionMailer::Base
  def signup(user)
    setup   user, "sales@editfu.com"
    subject "Welcome to EditFu. Now meet the ninjas."
  end

  def editor_invitation(user)
    setup   user, "noreply@editfu.com"
    subject "Content editor invitation."
  end

  def reset_password(user)
    setup   user, "noreply@editfu.com"
    subject "EditFu password reset"
  end

  def plan_change(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu plan change.'  
  end

  def credit_card_changes(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu credit card changes.'
  end

  def account_cancellation(user)
    setup   user, "sales@editfu.com"
    subject 'EditFu account cancellation.'
  end

  def owner_subdomain_changes(user)
    setup   user, "noreply@editfu.com"
    subject 'EditFu subdomain changes.'
  end

  def editor_subdomain_changes(owner, editor)
    setup   editor, "noreply@editfu.com"
    subject 'Content editing system address changes.'
    body    :owner => owner, :editor => editor
  end

  def owner_email_changes(user)
    setup   user, "noreply@editfu.com"
    subject 'EditFu email address.'
  end

  def editor_email_changes(user)
    setup   user, "noreply@editfu.com"
    subject 'Content editing system email address change.'
  end

  def content_update_error(editor, message)
    setup   editor.owner, "noreply@editfu.com"
    subject 'EditFu content update error.'
    body    :editor => editor, :owner => editor.owner, :message => message
  end

  def card_expiration(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu billing credit card.'
  end

  def card_has_expired(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu billing credit card.'
  end

  def trial_expiration(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu trial.'
  end
  
  def trial_expiration_reminder(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu trial reminder.'
  end

  def hold(user)
    setup   user, "billing@editfu.com"
    subject 'EditFu account hold'
  end
  
  def tomorrow_holded_status
    setup   user, "billing@editfu.com"
    subject 'EditFu account hold'
  end
  
  def hold_report owners_hash
    from          "billing@editfu.com"
    recipients    "billing@editfu.com"
    content_type  'text/html'
    subject       'Owners report'
    body          owners_hash
  end

  private

  def setup(user, email="edit.fu.cms@gmail.com")
    from         email
    recipients   user.email
    content_type 'text/html'
    body         :user => user
  end
end
