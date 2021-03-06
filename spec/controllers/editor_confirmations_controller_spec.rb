require 'spec_helper'

describe EditorConfirmationsController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @editor = Factory.create(:editor, :owner => @owner)
  end

  describe "update" do
    it "should work" do
      post :update, :confirmation_token => @editor.confirmation_token, 
        :editor => {
          :user_name => 'Sergey', 
          :password => '123456', :password_confirmation => '123456'
        }

      response.should redirect_to(sites_path)
      @editor.reload.confirmed?.should be_true
    end

    it "should reject site owners" do
      post :update, @owner.attributes

      response.should redirect_to(new_user_session_url)
      assigns(:editor).should be_nil
    end

    it "should run password validations" do
      post :update, :confirmation_token => @editor.confirmation_token, 
        :editor => { :user_name => 'Sergey' }

      assigns(:editor).confirmed?.should be_false
      response.should render_template(:edit)
    end

    it "should not allow to change email" do
      old_email = @editor.email
      post :update, :confirmation_token => @editor.confirmation_token, 
        :editor => {
          :user_name => 'Sergey', :email => 'new_email@malinator.com',
          :password => '123456', :password_confirmation => '123456'
        }

      @editor.reload.email.should == old_email
    end
  end
end
