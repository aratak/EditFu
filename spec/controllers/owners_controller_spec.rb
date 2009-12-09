require 'spec_helper'

describe OwnersController do
  include Devise::TestHelpers

  describe "create" do
    it "should work" do
      post :create, :owner => Factory.attributes_for(:owner)

      response.should redirect_to(root_path)
      assigns(:owner).new_record?.should be_false
    end

    it "should run password verification" do
      attributes = Factory.attributes_for(:owner, :password_confirmation => 'invalid')
      post :create, :owner => attributes

      response.should render_template(:new)
      assigns(:owner).should have(1).error_on(:password)
      assigns(:owner).new_record?.should be_true
    end
  end
end
