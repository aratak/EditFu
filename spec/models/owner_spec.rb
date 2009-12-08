require 'spec_helper'

describe Owner do
  before :each do
    @owner = Owner.new :name => 'owner', :email => 'owner@malinator.com',
      :password => '123456', :confirmed_password => '123456'
  end

  describe 'save' do
    it "should deliver email instructions to new owner" do
      ActionMailer::Base.deliveries.clear
      @owner.save!

      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.first
      email.to.first.should == @owner.email
      email.body.should match("/owners/confirmation")
      email.body.should match(@owner.confirmation_token)
    end
  end

  describe "add_editor" do
    before :each do
      @owner.save!
    end

    it "should create an editor" do
      editor = @owner.add_editor('editor@malinator.com')

      editor.name.should == 'editor'
      editor.email.should == 'editor@malinator.com'

      @owner.editors.should include(editor)
      editor.owner.should == @owner
      editor.confirmed?.should be_false
    end
  end
end
