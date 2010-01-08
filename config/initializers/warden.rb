Devise::FLASH_MESSAGES << :disabled

Warden::Manager.after_set_user do |user, auth|
  if user && !user.enabled?
    auth.logout(:user)
    throw :warden, :scope => :user, :message => :disabled
  end
end
