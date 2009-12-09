require 'spec_helper'

describe Editor do
  before :each do
    @editor = Factory.build(:editor)
    ActionMailer::Base.deliveries.clear
  end

  describe 'save' do
    it "should deliver email instructions to new editor" do
      @editor.save!

      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.first
      email.to.first.should == @editor.email
      email.body.should match("invited by #{@editor.owner.email}")
      email.body.should match("/editors/confirmation")
      email.body.should match(@editor.confirmation_token)
    end
  end

  describe 'sites' do
    it "should return actual editor sites" do
    end
  end
end
