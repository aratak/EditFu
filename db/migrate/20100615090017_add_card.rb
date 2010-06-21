class AddCard < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.integer :owner_id
      t.string :display_number
      t.string :display_expiration_date
      t.string :subscription_id
    end
    
    remove_column :users, :subscription_id
    
  end

  def self.down
    drop_table :cards
    add_column :users, :subscription_id, :string, :limit => 13
  end
end
