class RemoveHoldAttribute < ActiveRecord::Migration
  def self.up
    remove_column :users, :hold
    remove_column :users, :card_exp_date
    remove_column :users, :card_number
  end

  def self.down
    add_column :users, :hold, :boolean
    add_column :users, :card_exp_date, :date
    add_column :users, :card_number, :string, :limit => 20
  end
end
