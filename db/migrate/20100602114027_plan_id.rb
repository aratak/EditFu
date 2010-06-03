class PlanId < ActiveRecord::Migration
  PLANS = {
    :trial => Plan::TRIAL.id, 
    :unlimited_trial => Plan::UNLIMITED_TRIAL.id, 
    :free => Plan::FREE.id, 
    :professional => Plan::PROFESSIONAL.id
  }

  def self.up
    add_column :users, :plan_id, :integer
    PLANS.each do |key, val|
      Owner.update_all "plan_id = #{val}", "plan = '#{key}'"
    end
    remove_column :users, :plan
  end

  def self.down
    add_column :users, :plan, :string
    PLANS.each do |key, val|
      Owner.update_all "plan = '#{key}'", "plan_id = #{val}"
    end
    remove_column :users, :plan_id
  end
end
