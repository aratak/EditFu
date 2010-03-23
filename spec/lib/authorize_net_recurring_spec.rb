require 'spec_helper'

describe AuthorizeNetRecurring do
  describe ".create" do
    before :each do
      @card = Factory.build :card
      @owner = Factory.build :owner
      @owner.confirmed_at = Date.today
      @gateway = mock('gateway')

      @subscription_id = '12345'
    end

    it "should set owner's subscription_id" do
      response = ActiveMerchant::Billing::Response.new(
        true, nil, :subscription_id => @subscription_id
      )
      @gateway.should_receive(:recurring).with(100, @card, anything).
        and_return(response)

      AuthorizeNetRecurring.create(@gateway, 100, @owner, @card)
      @owner.subscription_id.should == @subscription_id
    end

    it "should raise error when response is not success" do
      @owner.subscription_id = @subscription_id
      message = 'fatal error message'
      response = ActiveMerchant::Billing::Response.new(false, message)
      @gateway.should_receive(:recurring).and_return(response)

      lambda {
        AuthorizeNetRecurring.create(@gateway, 100, @owner, @card)
      }.should raise_error(PaymentSystemError, message)
      @owner.subscription_id.should be_nil
    end

    it "should ignore response error if subscription_id was set" do
      response = ActiveMerchant::Billing::Response.new(
        false, "some error message", :subscription_id => @subscription_id
      )
      @gateway.should_receive(:recurring).and_return(response)

      AuthorizeNetRecurring.create(@gateway, 100, @owner, @card)
      @owner.subscription_id.should == @subscription_id
    end
  end

  describe ".cancel" do
    before :each do
      @owner = Factory.build :owner, :subscription_id => '12345'
      @gateway = mock('gateway')
    end

    it "should clear owner's subscription_id" do
      response = ActiveMerchant::Billing::Response.new(true, nil)
      @gateway.should_receive(:cancel_recurring).with(@owner.subscription_id).
        and_return(response)

      AuthorizeNetRecurring.cancel(@gateway, @owner)
      @owner.subscription_id.should be_nil
    end

    it "should raise error if response wasn't success" do
      response = ActiveMerchant::Billing::Response.new(false, 'error message')
      @gateway.should_receive(:cancel_recurring).and_return(response)

      lambda {
        AuthorizeNetRecurring.cancel(@gateway, @owner)
      }.should raise_error(PaymentSystemError)
      @owner.subscription_id.should_not be_nil
    end

    it "should not contact server if subscription_id is nil" do
      @owner.subscription_id = nil

      @gateway.should_not_receive(:cancel_recurring)
      AuthorizeNetRecurring.cancel(@gateway, @owner)
    end
  end
end
