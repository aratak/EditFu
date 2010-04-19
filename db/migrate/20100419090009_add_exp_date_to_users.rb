class AddExpDateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :card_exp_date, :date
  end

  def self.down
    remove_column :users, :card_exp_date
  end
end
