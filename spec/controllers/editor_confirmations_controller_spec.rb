require 'spec_helper'

describe EditorConfirmationsController do
  include Devise::TestHelpers

  before :each do
    @owner = User.new :name => 'owner', :email => 'owner@malinator.com',
      :password => '123456', :confirmed_password => '123456'
    @owner.save!

    @editor = @owner.add_editor('editor@malinator.com')
  end

  describe "create" do
    it "should work" do
      post :create, :confirmation_token => @editor.confirmation_token, 
        :user => {
          :name => 'Sergey', 
          :password => '123456', :password_confirmation => '123456'
        }

      response.should redirect_to(root_path)
      @editor.reload.confirmed?.should be_true
    end

    it "should reject site owners" do
      post :create, @owner.attributes

      response.should redirect_to(root_path)
      assigns(:user).errors.should be_empty
      assigns(:user).confirmed?.should be_false
    end

    it "should run password validations" do
      post :create, :confirmation_token => @editor.confirmation_token, 
        :user => { :name => 'Sergey' }

      assigns(:user).confirmed?.should be_false
      response.should render_template(:edit)
    end

    it "should not allow to change email" do
      post :create, :confirmation_token => @editor.confirmation_token, 
        :user => {
          :name => 'Sergey', :email => 'new_email@malinator.com',
          :password => '123456', :password_confirmation => '123456'
        }

      @editor.reload.email.should == 'editor@malinator.com'
    end
  end
end
