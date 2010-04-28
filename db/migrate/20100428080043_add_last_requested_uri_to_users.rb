class AddLastRequestedUriToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_requested_uri, :string, :limit => 128
  end

  def self.down
    remove_column :users, :last_requested_uri
  end
end
