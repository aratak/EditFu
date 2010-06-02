require 'spec_helper'

shared_examples_for "general owners tests" do

  describe 'save' do
    it "should deliver email instructions to new owner" do
      owner = Factory.build(:owner)
      ActionMailer::Base.deliveries.clear
      owner.save!

      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.first
      email.to.first.should == owner.email
      email.body.should match("/owners/confirmation")
      email.body.should match(owner.confirmation_token)
    end

  end

  describe "#set_free_plan" do
    it "should work" do
      owner = Factory.create :owner
      site = Factory.create :site, :owner => owner
      4.times do
        Factory.create :page, :site => site
      end
      pages = site.pages

      site2 = Factory.create :site, :owner => owner
      Factory.create :page, :site => site2
      
      owner.set_free_plan([site], pages[1..2])

      owner.reload
      owner.plan.should == "free"
      owner.card_number.should be_nil

      owner.sites.should == [site]
      owner.pages.should == pages[1..2]
    end

    it "should cancel recurring if previous plan was professional" do
      owner = Factory.create :owner, :plan => 'professional'
      PaymentSystem.should_receive(:cancel_recurring).with(owner)

      owner.set_free_plan([], [])
    end

    it "should not cancel recurring if previous plan was trial" do
      PaymentSystem.should_not_receive(:cancel_recurring)
      @owner.set_free_plan([], [])
    end
  end

  describe "#set_card" do
    it "should update recurring" do
      card = Factory.build :card
      owner = Factory.create :owner, :plan => 'professional'

      PaymentSystem.should_receive(:update_recurring).with(owner, card)
      owner.set_card card
    end

    it "should not call PaymentSystem if plan is not professional" do
      card = Factory.build :card
      owner = Factory.create :owner, :plan => 'free'

      PaymentSystem.should_not_receive(:update_recurring)
      owner.set_card card
    end
  end  

  describe "#set_professional_plan" do
    it "should work" do
      card = Factory.build :card, :expiration => '01/2020'
      PaymentSystem.should_receive(:recurring).with(@owner, card)
      @owner.set_professional_plan(card)

      @owner.reload
      @owner.plan.should == "professional"
      @owner.card_number.should == card.display_number
      @owner.card_exp_date.should == Date.new(2020, 1, 1);
    end
    
    it "should not work twice" do
      card = Factory.build :card
      @owner.set_professional_plan(card)
      @owner.card_number = nil
      @owner.set_professional_plan(card)
      
      @owner.card_number.should be_nil
    end
  end

  describe "#trial_period_expired?" do
    it "should work" do
      now = DateTime.civil(2009, 12, 1)
      Time.stub(:now).and_return { now.to_time }

      trial = Factory.create :owner
      free = Factory.create :owner, :plan => 'free'
      trial.confirm!
      free.confirm!

      trial.trial_period_expired?.should be_false
      free.trial_period_expired?.should be_false

      now = 1.day.from_now
      trial.trial_period_expired?.should be_false
      free.trial_period_expired?.should be_false

      now = 1.month.from_now
      trial.trial_period_expired?.should be_true
      free.trial_period_expired?.should be_false

      trial.plan = "professional"
      trial.save
      trial.trial_period_expired?.should be_false
    end
  end

  describe "billing_day" do
    it "should return mday of confirm_date" do
      @owner.confirmed_at = DateTime.new(2010, 2, 25)
      @owner.billing_day.should == 25
    end

    it "should round mday to 1 if it's greater then 28" do
      @owner.confirmed_at = DateTime.new(2010, 3, 29)
      @owner.billing_day.should == 1
    end
  end

  describe "billing_date" do
    before :each do 
      today = Date.new(2010, 3, 23)
      Date.stub(:today).and_return(today)
      Date.stub(:current).and_return(today)
    end

    it "should return the current month billing day if it is in future" do
      @owner.confirmed_at = DateTime.new(2010, 2, 25)
      @owner.next_billing_date.should == Date.new(2010, 3, 25)
    end

    it "should return the next month billing day current month' one is in the past" do
      @owner.confirmed_at = DateTime.new(2010, 2, 20)
      @owner.prev_billing_date.should == Date.new(2010, 3, 20)
      @owner.next_billing_date.should == Date.new(2010, 4, 20)
    end

    it "should return nil in prev_billing_date if there aren't bills yet" do
      @owner.confirmed_at = DateTime.new(2010, 3, 1)
      @owner.prev_billing_date.should be_nil
    end
  end
  
  describe "set_default_domain_name" do

    should_validate_presence_of(:domain_name)
    
    # should_validate_uniqueness_of(:domain_name)
    
    it "should automaticly generate domain name from company name" do
      owner = Factory.create(:owner, :company_name => "Test company name")
      owner.domain_name = "test_company_name"
    end

  end  
  
end


describe Owner, "" do
  before :each do
    @owner = Factory.create(:owner)
  end
  it_should_behave_like "general owners tests"
  
  describe "#validate" do
    context "free plan" do
      it "should work if there are one site and three pages" do
        site = Factory.create :site, :owner => @owner
        3.times do
          Factory.create :page, :site => site
        end

        @owner.plan = "free"
        @owner.save.should be_true
      end

      it "should fail if there are too many sites" do
        2.times do
          Factory.create :site, :owner => @owner
        end

        @owner.plan = "free"
        @owner.save.should be_false
      end

      it "should fail if there are too many pages" do
        site = Factory.create :site, :owner => @owner
        4.times do
          Factory.create :page, :site => site
        end

        @owner.plan = "free"
        @owner.save.should be_false
      end
    end

    context "trial plan" do
      it "should not be set after plan was changed to free or professional" do
        @owner.plan = "free"
        @owner.save!

        @owner.plan = "trial"
        lambda { @owner.save }.should raise_error
      end
    end
  end

  it "should destroy editors if plan was changed to free" do
    Factory.create :editor, :owner => @owner

    @owner.plan = "free"
    @owner.save
    @owner.editors.should be_empty
  end
  
  describe "#destroy" do
    before(:each) do
      2.times do
        Factory(:site, :owner => @owner)
        Factory(:editor, :owner => @owner)
      end
    end

    it "should destroy owner's sites" do
      @owner.destroy
      Site.find_all_by_owner_id(@owner.id).should == []
    end

    it "should destroy owner's editors" do
      @owner.destroy
      Editor.find_all_by_owner_id(@owner.id).should == []
    end

    it "should cancel recurring if plan is professional" do
      owner = Factory.create :owner, :plan => 'professional'
      PaymentSystem.should_receive(:cancel_recurring).with(owner)
      owner.destroy
    end
  end
  
end

describe Owner, "(buddy)" do
  before :each do
    @owner = Factory.create(:free_owner)
  end
  it_should_behave_like "general owners tests"

  describe "unlimited trial verification" do
    
    it "should be +false+ as default" do
      @owner.should_not be_unlimited_trial
    end

    it "should be protected from massive update (attr_accessible)" do
      @owner.update_attributes(:unlimited_trial => true)
      @owner.should_not be_unlimited_trial
    end
    
    it "should set plan to 'trial', when me toggle to true" do
      @owner.plan = 'free'
      @owner.plan.should == 'free'
      
      @owner.unlimited_trial = true
      @owner.plan.should == 'unlimited_trial'
      @owner.should be_valid
    end
    
  end
  
end


# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  email                :string(100)     not null
#  encrypted_password   :string(40)
#  password_salt        :string(20)
#  confirmation_token   :string(20)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(20)
#  remember_token       :string(20)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  domain_name          :string(255)
#  owner_id             :integer(4)
#  type                 :string(10)      not null
#  plan                 :string(255)     default("trial")
#  card_number          :string(20)
#  subscription_id      :string(13)
#  enabled              :boolean(1)      default(TRUE), not null
#  user_name            :string(255)
#  card_exp_date        :date
#  company_name         :string(255)
#  hold                 :boolean(1)
#

