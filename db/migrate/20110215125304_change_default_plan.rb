class ChangeDefaultPlan < ActiveRecord::Migration
  def self.up
    change_column_default :users, :plan_id, Plan::UNLIMITEDTRIAL.id
  end

  def self.down
    change_column_default :users, :plan_id, Plan::TRIAL.id
  end
end
