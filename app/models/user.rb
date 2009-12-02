class User < ActiveRecord::Base
  devise :all

  has_many :sites, :foreign_key => 'owner_id'

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
end
