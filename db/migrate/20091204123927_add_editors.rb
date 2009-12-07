class AddEditors < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.integer :owner_id
      t.change :encrypted_password, :string, :limit => 40, :null => true
      t.change :password_salt, :string, :limit => 20, :null => true
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :owner_id
      t.change :encrypted_password, :string, :limit => 40, :null => false
      t.change :password_salt, :string, :limit => 20, :null => false
    end
  end
end
