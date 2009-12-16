class User < ActiveRecord::Base
  devise :all, :except => :confirmable
  include Devise::Models::Confirmable

  validates_presence_of :name

  attr_accessible :name, :email, :password, :password_confirmation

  def require_password
    @password_required = true
  end

  def owner?
    kind_of?(Owner)
  end

  protected

  def password_required?
    @password_required
  end
end
