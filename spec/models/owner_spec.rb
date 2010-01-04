require 'spec_helper'

describe Owner do
  before :each do
    @owner = Factory.create(:owner)
  end

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

    it "should destroy editors if plan was changed to free" do
      Factory.create :editor, :owner => @owner

      @owner.plan = "free"
      @owner.save
      @owner.editors.should be_empty
    end
  end

  describe "add_editor" do
    it "should create an editor" do
      editor = @owner.add_editor('editor@malinator.com')

      editor.name.should == 'editor'
      editor.email.should == 'editor@malinator.com'

      @owner.editors.should include(editor)
      editor.owner.should == @owner
      editor.confirmed?.should be_false
    end
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

  describe "#validate" do
    describe "free plan" do
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

    describe "trial plan" do
      it "should not be set after plan was changed to free or professional" do
        @owner.plan = "free"
        @owner.save!

        @owner.plan = "trial"
        lambda { @owner.save }.should raise_error
      end
    end
  end

  describe "#set_professional_plan" do
    it "should work" do
      card = Factory.build :card
      PaymentSystem.should_receive(:recurring).with(@owner, card)
      @owner.set_professional_plan(card)

      @owner.reload
      @owner.plan.should == "professional"
      @owner.card_number.should == card.display_number
    end
    
    it "should not work twice" do
      card = Factory.build :card
      @owner.set_professional_plan(card)
      @owner.card_number = nil
      @owner.set_professional_plan(card)
      
      @owner.card_number.should be_nil
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
end
