class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer       :owner_id
      t.date          :start_at
      t.date          :end_at
      t.integer       :price
      
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
