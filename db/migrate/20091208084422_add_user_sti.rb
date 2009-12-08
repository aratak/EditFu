class AddUserSti < ActiveRecord::Migration
  def self.up
    add_column :users, :type, :string, :limit => 10
    execute 'UPDATE users SET type = "owner" WHERE owner_id IS NULL'
    execute 'UPDATE users SET type = "editor" WHERE owner_id IS NOT NULL'
    #change_column_null :users, :type, false
  end

  def self.down
    remove_column :users, :type
  end
end
