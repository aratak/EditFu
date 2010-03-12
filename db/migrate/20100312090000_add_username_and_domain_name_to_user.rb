class AddUsernameAndDomainNameToUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :name, :domain_name
    add_column :users, :user_name, :string
    execute 'UPDATE users SET user_name = domain_name'
  end

  def self.down
    remove_column :users, :user_name
    rename_column :users, :domain_name, :name
  end
end
