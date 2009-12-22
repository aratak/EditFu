class AddBillingToOwner < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :card_number, :limit => 20
      t.date :card_expiration
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
    end
  end

  def self.down
    remove_columns :users, :card_number, :card_expiration, :first_name, :last_name
  end
end
