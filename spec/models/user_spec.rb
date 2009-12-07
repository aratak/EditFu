require 'spec_helper'

describe User do
  describe "add_editor" do
    it "should create an editor and send invitation email" do
      owner = User.new :name => 'owner', :email => 'owner@malinator.com',
        :password => '123456', :confirmed_password => '123456'
      owner.save!
      ActionMailer::Base.deliveries.clear

      editor = owner.add_editor('editor@malinator.com')

      editor.name.should == 'editor'
      editor.email.should == 'editor@malinator.com'

      owner.editors.should include(editor)
      editor.owner.should == owner
      editor.confirmed?.should be_false

      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.first
      email.to.first.should == editor.email
      email.body.should match(/invited by #{owner.email}/)
    end
  end
end
