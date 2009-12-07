class User < ActiveRecord::Base
  devise :all

  has_many :sites, :foreign_key => 'owner_id', :dependent => :destroy
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  has_many :editors, :class_name => 'User', :foreign_key => 'owner_id', 
    :dependent => :destroy

  validates_presence_of :name

  attr_accessible :name, :email, :password, :password_confirmation

  def add_editor(email)
    name = email[0, email.index('@')]
    editors.create! :name => name, :email => email, :owner => self
  end

  def editor?
    !!owner
  end

  protected

  def password_required?
    !editor? && new_record? || !password.nil? || !password_confirmation.nil?
  end
end
