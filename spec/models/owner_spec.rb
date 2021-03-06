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

  describe "#set_card" do
    it "should update recurring" do
      owner = Factory.create :owner
      owner.set_plan Plan::PROFESSIONAL
      card = Factory.create :card
      owner.card = card
      owner.reload
      cardid = card.id
      # owner.set_card(card)

      card2_attrs = Factory.attributes_for(:card) #Factory.create :card, :owner => owner
      PaymentSystem.should_receive(:recurring).with(card)
      owner.card.update_attributes(card2_attrs)
      # owner.save
      owner.card.id.should be(cardid)
    end

    it "should not call PaymentSystem if plan is not professional" do
      owner = Factory.create :owner
      owner.set_plan Plan::FREE
      card = Factory.build :card, :owner => owner

      PaymentSystem.should_not_receive(:update_recurring)
      owner.card = card
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
  
  describe "payment plan" do
    
    context "should has method 'has_payment_plan?'" do

      Plan::UNPAYMENTS.each do |plan|
        it "and should return false" do
          owner = Factory.build(:owner)
          owner.stub!(:plan).and_return(plan)
          owner.has_payment_plan?.should be_false
        end
      end

      Plan::PAYMENTS.each do |plan|
        it "and should return true" do
          owner = Factory.build(:owner)
          owner.stub!(:plan).and_return(plan)
          owner.has_payment_plan?.should be_true
        end
      end

    end

    context "should has method 'has_no_payment_plan?'" do

      Plan::UNPAYMENTS.each do |plan|
        it "and should return true" do
          owner = Factory.build(:owner)
          owner.stub!(:plan).and_return(plan)
          owner.has_no_payment_plan?.should be_true
        end
      end

      Plan::PAYMENTS.each do |plan|
        it "and should return false" do
          owner = Factory.build(:owner)
          owner.stub!(:plan).and_return(plan)
          owner.has_no_payment_plan?.should be_false
        end
      end

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

        @owner.set_plan Plan::FREE
        @owner.save.should be_true
      end

      it "should fail if there are too many sites" do
        2.times do
          Factory.create :site, :owner => @owner
        end

        @owner.set_plan Plan::FREE
        @owner.save.should be_false
      end

      it "should fail if there are too many pages" do
        site = Factory.create :site, :owner => @owner
        4.times do
          Factory.create :page, :site => site
        end

        @owner.set_plan Plan::FREE
        @owner.save.should be_false
      end
    end

    context "trial plan" do
      it "should not be set after plan was changed to free or professional" do
        @owner.set_plan Plan::FREE
        @owner.save!

        @owner.set_plan Plan::TRIAL
        @owner.save.should be_false
      end
    end

    context "professional plan" do
      before :each do
        @card = Factory.build :card
        @owner.card = @card
        @owner.confirmed_at = Date.today
        @owner.reload
        @gateway = mock('gateway')
      end

      it "should has been set with card" do
        @owner.set_plan(Plan::PROFESSIONAL)
        @owner.card = @card
        @owner.valid?.should be_true
        @owner.card.should == @card
      end
      
    end
    
  end

  it "should destroy editors if plan was changed to free" do
    Factory.create :editor, :owner => @owner

    @owner.set_plan Plan::FREE
    @owner.valid?.should be_false
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
      owner = Factory.create(:owner)
      owner.set_plan(Plan::PROFESSIONAL)
      owner.card = Factory.build(:card)
      owner.save
      owner.reload

      owner.card.should_not be_nil
      owner.plan.should be(Plan::PROFESSIONAL)
      
      
      PaymentSystem.should_receive(:cancel_recurring).with(owner.card)
      owner.destroy
    end
  end
  
end

describe Owner, "and plan relation" do
  
  should_belong_to :plan
  should_have_many :subscriptions
  
  describe "'plan_was'/'plan_changed' method" do
    before :each do
      @owner = Factory.create(:owner)
    end
    
    it "'plan_was' should be" do
      @owner.should be_respond_to(:plan_was)
    end
    
    it "'plan_changed?' should be" do
      @owner.should be_respond_to(:"plan_changed?")
    end
    
    it "should recive the previous plan" do
      @owner.set_plan Plan::FREE
      @owner.plan_was.should == Plan::TRIAL
    end
    
    it "should retive the current plan after save" do
      @owner.set_plan Plan::FREE
      @owner.save(false)
      @owner.plan_was.should == Plan::FREE
    end
    
    it "should be true after changing" do
      @owner.set_plan Plan::FREE
      @owner.plan_changed?.should be_true
    end
    
    it "should be false after changing and saving" do
      @owner.set_plan Plan::FREE
      @owner.save
      @owner.plan_changed?.should be_false
    end
    
    it "should have 'plan_was?' method" do
      @owner.should be_respond_to(:"plan_was?")
    end
    
    it "should have 'plan_changed_to?' method" do
      @owner.should be_respond_to(:"plan_changed_to?")
    end
    
    Plan.all.each do |p|
      before :each do
        @owner.set_plan Plan::FREE
        @plan = p
      end

      it "'plan_changed_to?' should be correct" do
        @owner.stub!(:plan).and_return @plan 
      end

      it "'plan_was?' method should be correct" do
        if @owner.plan_was == @plan 
          @owner.plan_was?(@plan).should be_true 
        else
          @owner.plan_was?(@plan).should be_false
        end
      end

      it "should have 'plan_was_#{p.identificator}?' method" do
        @owner.should be_respond_to(:"plan_was_#{@plan.identificator}?")
      end

      it "'plan_was_#{p.identificator}?' should be correct" do
        @owner.send(:"plan_was_#{@plan.identificator}?").should be_equal(@owner.plan_was?(@plan))
      end

    end
    
    
  end
  
  describe "should be able to" do
    before :each do
      @owner = Factory.create(:owner)
    end
    
    it "add editor" do
      proc { 
        @owner.add_editor("user@mailinator.com").should_not be_nil
      }.should change(@owner.editors, :count).by(1)
    end
    
    it "find site" do
      site = Factory.create(:site, :owner => @owner)
      @owner.find_site(site.id).should == site
    end

    it "not find site" do
      another_owner = Factory.create(:owner)
      site = Factory.create(:site, :owner => another_owner)
      @owner.find_site(site.id).should be_nil
    end
    
    it "find page" do
      site = Factory.create(:site, :owner => @owner)
      page = Factory.create(:page, :site => site)
      @owner.find_page(site.id, page.id).should == page
    end

    context "not find page" do
      
      before :each do
        @site = Factory.create(:site, :owner => @owner)
        @page = Factory.create(:page, :site => @site)

        @another_owner = Factory.create(:owner)
        @another_site = Factory.create(:site, :owner => @another_owner)
        @another_page = Factory.create(:page, :site => @another_site)
      end
      
      it { @owner.find_page(@another_site.id, @page.id).should be_nil }
      it { @owner.find_page(@site.id, @another_page.id).should be_nil }
      it { @owner.find_page(@another_site.id, @another_page.id).should be_nil }
    end
    
  end

  
end

describe Owner, "and subscirptions" do
  
  before :each do
    @owner = Factory.create :owner
  end

  context "#subscription" do
    
    it "should be first" do 
      @owner.subscriptions.count.should == 1
    end

    
    it "should be second" do 
      @owner.set_plan Plan::PROFESSIONAL
      @owner.save
      @owner.subscriptions.count.should == 2
    end
    
    it "first subscription should has todays end date" do
      @owner.set_plan Plan::PROFESSIONAL
      @owner.save
      
      @owner.subscriptions.previous.ends_at.to_date.should == Date.today
    end
    
    Plan.all.each do |plan|
      context "should has correct period with #{plan.name}" do

        before :each do
          @plan = plan
          @owner.set_plan @plan
          @owner.save
        end

        it "should be correct" do 
          (@owner.subscriptions.last.starts_at.to_date + @owner.plan.period.month).should == @owner.subscriptions.last.ends_at.to_date
        end

      end
    end
    
    it "should unhold user" do
      @owner.hold = true
      @owner.close_latest_subscription
      @owner.send(:update_without_callbacks)
      
      @owner.create_next_subscription
      @owner.hold.should be_false
    end
    
  end
  
  
  context "should check credit card expiration" do
    
    before :each do
      @owner.set_plan Plan::PROFESSIONAL
    end
    
    it "should be expired" do
      @owner.card = Factory(:card, :display_expiration_date  => 1.week.ago)
      @owner.credit_card_expired?.should be_true

      @owner.card = Factory(:card, :display_expiration_date  => 1.day.ago)
      @owner.credit_card_expired?.should be_true
    end
    
    it "should not be expired" do
      @owner.card = Factory(:card, :display_expiration_date  => 1.week.since)
      @owner.credit_card_expired?.should be_false

      @owner.card = Factory(:card, :display_expiration_date  => 1.day.since)
      @owner.credit_card_expired?.should be_false
    end
    
  end
  
end

describe Owner, 'and delivers' do
  it "named_scope should work" do
    @owner = Factory(:owner)
    5.times { @owner.create_next_subscription }
    Subscription.ends_todays.count.should == 5
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
#  card_number          :string(20)
#  subscription_id      :string(13)
#  enabled              :boolean(1)      default(TRUE), not null
#  user_name            :string(255)
#  card_exp_date        :date
#  company_name         :string(255)
#  hold                 :boolean(1)
#  plan_id              :integer(4)
#

