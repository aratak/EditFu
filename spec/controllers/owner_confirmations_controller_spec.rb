require 'spec_helper'

describe OwnerConfirmationsController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
  end

  describe "show" do
    it "should confirm site owner" do
      get :show, :confirmation_token => @owner.confirmation_token

      @owner.reload.confirmed?.should be_true
      controller.current_user.should == @owner
    end

    it "should complain if user already confirmed" do
      confirmation_token = @owner.confirmation_token
      @owner.confirm!
      get :show, :confirmation_token => confirmation_token

      controller.current_user.should_not == @owner
    end
    
    it "should not confirm editor" do
      editor = Factory.create(:editor)

      get :show, :confirmation_token => editor.confirmation_token

      controller.current_user.should_not == editor
      editor.reload.confirmed?.should be_false
    end
  end
end
