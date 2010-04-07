class User < ActiveRecord::Base
  devise :all, :except => :confirmable
  include Devise::Models::Confirmable

  validates_presence_of :user_name
  validates_presence_of :current_password, :if => :current_password_required?

  attr_reader :current_password
  attr_accessor :current_password
  attr_accessible :user_name, :email, :current_password, :password, :password_confirmation

  def require_password
    @password_required = true
  end

  def require_current_password
    @current_password_required = true
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

  def validate
    if current_password_required? 
      if !current_password.blank? && password_digest_was(current_password) != encrypted_password_was
        errors.add(:current_password, "doesn't match")
      end
    end
  end

  def password_required?
    @password_required || password.present? || password_confirmation.present?
  end

  def current_password_required?
    @current_password_required && (password.present? || password_confirmation.present?)
  end

  def password_digest_was(password)
    self.class.encryptor_class.digest(password, self.class.stretches, password_salt_was, self.class.pepper)
  end
end
