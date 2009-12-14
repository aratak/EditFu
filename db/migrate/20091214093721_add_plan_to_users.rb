class AddPlanToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :plan, :string

    Owner.reset_column_information

    Owner.all.each do |owner|
      owner.plan = "trial"
      owner.save!
    end
  end

  def self.down
    remove_column :users, :plan
  end
end
