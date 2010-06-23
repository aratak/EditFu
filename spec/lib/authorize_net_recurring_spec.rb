require 'spec_helper'

describe AuthorizeNetRecurring do
  describe ".create" do
    before :each do
      @owner = Factory.build :owner
      @card = Factory.build :card, :owner => @owner
      @owner.confirmed_at = Date.today
      @gateway = mock('gateway')

      @subscription_id = '12345'
    end

    it "should set owner's subscription_id" do
      response = ActiveMerchant::Billing::Response.new(
        true, nil, :subscription_id => @subscription_id
      )
      @gateway.should_receive(:recurring). #with(100, @card, anything).
        and_return(response)

      AuthorizeNetRecurring.create(@gateway, 100, @card)
      @card.subscription_id.should == @subscription_id
    end

    it "should raise error when response is not success" do
      @card.subscription_id = @subscription_id
      message = 'fatal error message'
      response = ActiveMerchant::Billing::Response.new(false, message)
      @gateway.should_receive(:recurring).and_return(response)

      lambda {
        AuthorizeNetRecurring.create(@gateway, 100, @card)
      }.should raise_error(PaymentSystemError, message)
      @card.subscription_id.should be_nil
    end

    it "should ignore response error if subscription_id was set" do
      response = ActiveMerchant::Billing::Response.new(
        false, "some error message", :subscription_id => @subscription_id
      )
      @gateway.should_receive(:recurring).and_return(response)

      AuthorizeNetRecurring.create(@gateway, 100, @card)
      @card.subscription_id.should == @subscription_id
    end
  end

  describe 'update' do
    before :each do
      @owner = Factory.build :owner
      @card = Factory.build :card, :owner => @owner, :subscription_id => '12345'
      @gateway = mock('gateway')
    end

    it "should work" do
      response = ActiveMerchant::Billing::Response.new(true, nil)
      @gateway.should_receive(:update_recurring).and_return(response)

      lambda {
        AuthorizeNetRecurring.update(@gateway, @card)
      }.should_not change(@card, :subscription_id)
    end

    it "should raise error if response isn't success" do
      response = ActiveMerchant::Billing::Response.new(false, "some error")
      @gateway.should_receive(:update_recurring).and_return(response)

      lambda {
        AuthorizeNetRecurring.update(@gateway, @card)
      }.should raise_error(PaymentSystemError)
    end
  end

  describe ".cancel" do
    before :each do
      @owner = Factory.build :owner
      @card = Factory.build :card, :subscription_id => '12345', :owner => @owner
      @gateway = mock('gateway')
    end

    it "should clear owner's subscription_id" do
      response = ActiveMerchant::Billing::Response.new(true, nil)
      @gateway.should_receive(:cancel_recurring).with(@card.subscription_id).
        and_return(response)

      AuthorizeNetRecurring.cancel(@gateway, @card)
      @card.subscription_id.should be_nil
    end

    it "should raise error if response wasn't success" do
      response = ActiveMerchant::Billing::Response.new(false, 'error message')
      @gateway.should_receive(:cancel_recurring).and_return(response)

      lambda {
        AuthorizeNetRecurring.cancel(@gateway, @card)
      }.should raise_error(PaymentSystemError)
      @card.subscription_id.should_not be_nil
    end

    it "should not contact server if subscription_id is nil" do
      @card.subscription_id = nil

      @gateway.should_not_receive(:cancel_recurring)
      AuthorizeNetRecurring.cancel(@gateway, @card)
    end
  end
end
