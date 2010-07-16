require 'spec_helper'

describe Subscription do

  should_belong_to :owner
  should_validate_presence_of :starts_at, :ends_at, :price


  context "scopes" do
    
    before :each do
      @owner = Factory :owner
    end
    
    
    context "without subscriptions" do

      before :each do
        @owner.subscriptions.destroy_all
      end
      
      it "should has nil instead previous sbscr" do
        @owner.subscriptions.previous.should be_nil
      end
      
      it "should has nil instead last sbscr" do
        @owner.subscriptions.last.should be_nil
      end

    end

    it "should close previous subscription" do
      subscription = @owner.subscriptions.last
      @owner.set_plan Plan::PROFESSIONAL
      @owner.save
      subscription.ends_at.to_date.should == Date.today
    end
    
    it "should has 'price_in_dollars'" do
      @owner.subscriptions.last.stub!(:price).and_return(100)
      @owner.subscriptions.last.price_in_dollars.should == 1
    end
    
    it "should has setter 'price_in_dollars'" do
      @owner.subscriptions.last.price_in_dollars = 1
      @owner.subscriptions.last.price.should == 100
    end
    
    it "should set new owner plan" do
      @owner.subscriptions.create :starts_at => Time.now,
                                  :ends_at => 1.month.since,
                                  :plan => Plan::SINGLE,
                                  :price => Plan::SINGLE.price
      @owner.reload

      @owner.plan.should == Plan::SINGLE
    end
    
  end
  

end



# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  owner_id   :integer(4)
#  starts_at  :datetime
#  ends_at    :datetime
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer(4)
#

