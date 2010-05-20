class User < ActiveRecord::Base
  devise :all, :except => [:confirmable, :validatable]
  include Devise::Models::Confirmable

  EMAIL_REGEX = /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i

  validates_presence_of :email, :user_name
  validates_uniqueness_of :email
  validates_format_of :email, :with => EMAIL_REGEX
  validates_length_of :password, :within => 6..20, :if => :password_required?

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
    Mailer.deliver_reset_password(self)
  end

  def company_url
    'http://' + company_domain
  end

  def company_domain
    "#{subdomain}.#{BASE_DOMAIN}"
  end
  
  def full_name
    user_name || email
  end

  protected

  def validate
    super

    if password_required?
      if current_password_required? && 
        (current_password.blank? || password.blank? || password_confirmation.blank?)
        errors.add_to_base I18n.t('passwords.blank.change')
      elsif password.blank? || password_confirmation.blank?
        errors.add_to_base I18n.t('passwords.blank.new')
      end

      if password != password_confirmation
        errors.add_to_base I18n.t('passwords.dont_match')
      end

      if current_password_required? 
        if !current_password.blank? && password_digest_was(current_password) != encrypted_password_was
          errors.add_to_base I18n.t('passwords.current.invalid')
        end
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
