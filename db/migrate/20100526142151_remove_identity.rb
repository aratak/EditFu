class RemoveIdentity < ActiveRecord::Migration
  def self.up
    remove_column :users, :company_name
    rename_column :users, :identity, :company_name
  end

  def self.down
    add_column :users, :company_name, :string
    rename_column :users, :company_name, :identity
  end
end
