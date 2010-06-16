class AddCard < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.integer :owner_id
      t.string :display_number
      t.string :display_expiration_date
      t.string :subscription_id
    end
  end

  def self.down
    drop_table :cards
  end
end
