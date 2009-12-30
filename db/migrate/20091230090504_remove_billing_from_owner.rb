class RemoveBillingFromOwner < ActiveRecord::Migration
  def self.up
    remove_columns :users, :card_expiration, :first_name, :last_name
  end

  def self.down
    change_table :users do |t|
      t.date :card_expiration
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
    end
  end
end
