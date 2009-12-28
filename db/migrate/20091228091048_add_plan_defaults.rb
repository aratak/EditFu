class AddPlanDefaults < ActiveRecord::Migration
  def self.up
    change_column_default :users, :plan, 'trial'
  end

  def self.down
    change_column_default :users, :plan, nil
  end
end
