class AddHoldToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hold, :boolean
  end

  def self.down
    remove_column :users, :hold
  end
end
