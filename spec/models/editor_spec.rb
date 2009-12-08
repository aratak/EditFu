require 'spec_helper'

describe Editor do
  before :each do
    @owner = Owner.new :name => 'owner', :email => 'owner@malinator.com',
      :password => '123456', :confirmed_password => '123456'
    @owner.save!
    ActionMailer::Base.deliveries.clear

    @editor = @owner.editors.build :name => 'Editor', 
      :email => 'editor@malinator.com'
  end

  describe 'save' do
    it "should deliver email instructions to new editor" do
      @editor.save!

      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.first
      email.to.first.should == @editor.email
      email.body.should match("invited by #{@owner.email}")
      email.body.should match("/editors/confirmation")
      email.body.should match(@editor.confirmation_token)
    end
  end
end
