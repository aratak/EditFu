class AddOwnerToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :owner_id, :integer
  end

  def self.down
    remove_column :sites, :owner_id
  end
end
