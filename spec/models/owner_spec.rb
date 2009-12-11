require 'spec_helper'

describe Owner do
  before :each do
    @owner = Factory.build(:owner)
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
  end
end
