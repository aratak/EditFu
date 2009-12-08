require 'spec_helper'

describe OwnersController do
  include Devise::TestHelpers

  describe "create" do
    it "should work" do
      post :create, :owner => { 
        :name => 'test', :email => 'test@malinator.com',
        :password => '123456', :password_confirmation => '123456'
      }

      response.should redirect_to(root_path)
      assigns(:owner).new_record?.should be_false
    end

    it "should run password verification" do
      post :create, :user => {
        :name => 'test', :email => 'test@malinator.com'
      }

      response.should render_template(:new)
      assigns(:owner).should have(1).error_on(:password)
    end
  end
end
