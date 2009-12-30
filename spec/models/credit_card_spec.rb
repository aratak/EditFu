require 'spec_helper'

describe CreditCard do
  describe '#valid?' do
    it "should authorize card balance" do
      card = Factory.build :card

      gateway = mock('gateway')
      ActiveMerchant::Billing::AuthorizeNetGateway.stub(:new).and_return(gateway)
      gateway.should_receive(:authorize).with(CreditCard.recurring_amount, card).
        and_return(
          ActiveMerchant::Billing::Response.new(false, "error raised")
        )

      card.valid?.should be_false
      card.errors.on(:base).should_not be_nil
    end

    it "should not authorize balance if credit card is not valid" do
      card = Factory.build :card, :number => nil

      gateway = mock('gateway')
      ActiveMerchant::Billing::AuthorizeNetGateway.stub(:new).and_return(gateway)

      card.valid?.should be_false
    end
  end
end
