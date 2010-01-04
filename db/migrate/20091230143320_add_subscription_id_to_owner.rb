class AddSubscriptionIdToOwner < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_id, :string, :limit => 13
  end

  def self.down
    remove_column :users, :subscription_id
  end
end
