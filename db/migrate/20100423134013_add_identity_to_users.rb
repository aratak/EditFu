class AddIdentityToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :identity, :string
  end

  def self.down
    remove_column :users, :identity
  end
end
