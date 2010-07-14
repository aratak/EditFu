class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer       :owner_id
      t.datetime      :starts_at
      t.datetime      :ends_at
      t.integer       :price
      
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
