require 'spec_helper'

describe ExtCreditCard do
  describe "initialize" do
    it "should call parent constructor and update @expiration attribute" do
      card = ExtCreditCard.new :first_name => 'John', :expiration => '02/2020'
      card.first_name.should == 'John'
      card.expiration.should == '02/2020'
    end
  end

  describe "before_validate" do
    it "should parse @expiration attribute and update @year and @month" do
      card = ExtCreditCard.new :expiration => '02/2020'
      card.valid?
      card.month.should == 2
      card.year.should == 2020
    end

    it "should update @year and @month only if @expiration presents" do
      card = ExtCreditCard.new :month => 2, :year => 2020
      card.valid?
      card.month.should == 2
      card.year.should == 2020
    end

    it "should update @year and @month only if @expiration has valid format" do
      card = ExtCreditCard.new :expiration => 'xx/xxxx', :month => 2, :year => 2020
      card.valid?
      card.year.should == 2020
      card.month.should == 2
    end
  end

  describe "validate" do
    it "should validate expiration presense" do
      card = ExtCreditCard.new :expiration => ''
      card.valid?
      card.errors.on(:expiration).should == 'cannot be empty'
    end

    it "should validate expiration format" do
      card = ExtCreditCard.new :expiration => 'xx/xxxx'
      card.valid?
      card.errors.on(:expiration).should == 'is invalid'
    end

    it "should append year errors to expiration" do
      card = ExtCreditCard.new :expiration => '01/1900'
      card.valid?
      card.errors.on(:expiration).should == 'expired'
    end

    it "should append month errors to expiration" do
      card = ExtCreditCard.new :expiration => '13/2020'
      card.valid?
      card.errors.on(:expiration).should == 'is not a valid month'
    end

    it "should append errors to expiration only if it has no them" do
      card = ExtCreditCard.new :expiration => '13/1900'
      card.valid?
      card.errors.on(:expiration).should == 'is not a valid month'
    end
  end
end
