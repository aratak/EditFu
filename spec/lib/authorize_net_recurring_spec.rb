require 'spec_helper'

describe AuthorizeNetRecurring do
  describe ".create" do
    it "should set owner's subscription_id" do
      card = Factory.build :card
      owner = Factory.build :owner

      gateway = mock('gateway')
      response = ActiveMerchant::Billing::Response.new(
        true, nil, :subscription_id => '12345'
      )
      gateway.should_receive(:recurring).with(100, card, anything).
        and_return(response)

      AuthorizeNetRecurring.create(gateway, 100, owner, card).should equal(response)
      owner.subscription_id.should == '12345'
    end
  end

  describe ".cancel" do
    it "should clear owner's subscription_id" do
      owner = Factory.build :owner, :subscription_id => '12345'

      gateway = mock('gateway')
      response = ActiveMerchant::Billing::Response.new(true, nil)
      gateway.should_receive(:cancel_recurring).with(owner.subscription_id).
        and_return(response)

      AuthorizeNetRecurring.cancel(gateway, owner).should equal(response)
      owner.subscription_id.should be_nil
    end
  end
end
