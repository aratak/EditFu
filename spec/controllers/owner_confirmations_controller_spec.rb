require 'spec_helper'

describe OwnerConfirmationsController do
  include Devise::TestHelpers

  before :each do
    @owner = Owner.new :name => 'owner', :email => 'owner@malinator.com',
      :password => '123456', :confirmed_password => '123456'
    @owner.save!
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
      editor = @owner.add_editor('editor@malinator.com')

      get :show, :confirmation_token => editor.confirmation_token

      controller.current_user.should_not == editor
      editor.reload.confirmed?.should be_false
    end
  end
end
