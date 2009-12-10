require 'spec_helper'

describe Editor do
  describe 'save' do
    it "should deliver email instructions to new editor" do
      editor = Factory.build(:editor)
      ActionMailer::Base.deliveries.clear
      editor.save!

      ActionMailer::Base.deliveries.should_not be_empty
      email = ActionMailer::Base.deliveries.first
      email.to.first.should == editor.email
      email.body.should match("invited by #{editor.owner.email}")
      email.body.should match("/editors/confirmation")
      email.body.should match(editor.confirmation_token)
    end
  end

  describe 'sites' do
    it "should return actual editor sites" do
      editor = Factory.create(:editor)
      site1 = Factory.create(:site, :owner => editor.owner)
      site2 = Factory.create(:site, :owner => editor.owner)

      editor.pages << Factory.create(:page, :site => site1)
      editor.pages << Factory.create(:page, :site => site1)
      editor.pages << Factory.create(:page, :site => site2)

      editor.sites.should == [site1, site2]
    end
  end
end
