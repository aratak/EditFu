class User < ActiveRecord::Base
  devise :all

  has_many :sites, :foreign_key => 'owner_id'

  validates_presence_of :username
  validates_uniqueness_of :username
  attr_accessible :email, :password, :password_confirmation
end
