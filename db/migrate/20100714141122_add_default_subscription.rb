class AddDefaultSubscription < ActiveRecord::Migration
  def self.up
    Owner.all.each do |owner|
      if owner.subscriptions.empty? && !owner.confirmed_at.nil?
        owner.subscriptions.create :starts_at => owner.confirmed_at,
                             :ends_at => owner.confirmed_at + owner.plan.period.month,
                             :price => owner.plan.price,
                             :plan => owner.plan
      end
    end
  end

  def self.down
    Subscription.destroy_all
  end
end
