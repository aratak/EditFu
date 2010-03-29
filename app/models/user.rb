class User < ActiveRecord::Base
  devise :all, :except => :confirmable
  include Devise::Models::Confirmable

  validates_presence_of :user_name

  attr_accessible :user_name, :email, :password, :password_confirmation

  def require_password
    @password_required = true
  end

  def owner?
    kind_of?(Owner)
  end

  def editor?
    kind_of?(Editor)
  end

  def admin?
    kind_of?(Admin)
  end

  def send_reset_password_instructions
    generate_reset_password_token!
    Mailer.deliver_reset_password_instructions(self)
  end

  protected

  def password_required?
    @password_required
  end
end
