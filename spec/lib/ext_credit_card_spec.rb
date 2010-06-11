require 'spec_helper'

describe ExtCreditCard do
  before :each do
    @blank_message = I18n.t('activerecord.errors.messages.blank')
  end

  describe "initialize" do
    it "should call parent constructor and update @expiration attribute" do
      card = ExtCreditCard.new :first_name => 'John', :expiration => '02/2020'
      card.first_name.should == 'John'
      card.expiration.should == '02/2020'
    end
  end
  
  describe "invalid? method" do
    it "should be" do
      card = ExtCreditCard.new :first_name => 'John', :expiration => '02/2020'
      card.should be_respond_to(:invalid?)
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

    it "should update @year and @month to nils if @expiration has invalid format" do
      card = ExtCreditCard.new :expiration => 'xx/xxxx'
      card.valid?
      card.year.should == 0
      card.month.should == 0
    end
  end

  describe "validate" do
    it "should validate expiration presense" do
      card = ExtCreditCard.new :expiration => ''
      card.valid?
      card.errors.on(:expiration).should == @blank_message
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

    it "should require zip code" do
      card = ExtCreditCard.new :zip => ''
      card.valid?
      card.errors.on(:zip).should == @blank_message
    end

    it "should change blank error messages" do
      card = ExtCreditCard.new :first_name => ''
      card.valid?
      card.errors.on(:first_name).should == @blank_message
    end
  end
end
