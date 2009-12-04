class User < ActiveRecord::Base
  devise :all

  has_many :sites, :foreign_key => 'owner_id'

  validates_presence_of :name

  attr_accessible :name, :email, :password, :password_confirmation
end
