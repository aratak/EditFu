class RemoveRedirect < ActiveRecord::Migration
  def self.up
    remove_column :users, :last_requested_uri
  end

  def self.down
    add_column :users, :last_requested_uri, :string, :limit => 128
  end
end
