require 'spec_helper'

describe CreditCard do
  describe '#valid?' do
    it "should authorize valid card" do
      card = Factory.build :card, :number => '1'
      card.valid?.should be_true
    end

    it "should not authorize invalid card" do
      card = Factory.build :card, :number => '2'
      card.valid?.should be_false
      card.errors.on(:base).should_not be_nil
    end

    it "should not call authorized? if base validation fail" do
      card = Factory.build :card, :number => nil
      PaymentSystem.should_not_receive(:authorized?)

      card.valid?.should be_false
    end
  end
end
