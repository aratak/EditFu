require 'spec_helper'

describe UsersController do
  include Devise::TestHelpers

  describe "create" do
    it "should work" do
      post :create, :user => { 
        :name => 'test', :email => 'test@malinator.com',
        :password => '123456', :password_confirmation => '123456'
      }

      puts assigns(:user).errors.full_messages

      response.should redirect_to(root_path)
      assigns(:user).new_record?.should be_false
    end

    it "should run password verification" do
      post :create, :user => {
        :name => 'test', :email => 'test@malinator.com'
      }

      response.should render_template(:new)
      assigns(:user).should have(1).error_on(:password)
    end
  end
end
