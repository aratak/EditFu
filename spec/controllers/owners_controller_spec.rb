require 'spec_helper'

describe OwnersController do
  include Devise::TestHelpers

  integrate_views

  describe "#create" do
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

  describe "#destroy" do
    before(:each) do
      @owner = Factory(:owner)
      @owner.confirm!
      sign_in @owner
    end

    def do_delete
      delete :destroy
    end

    it "should redirect to root url" do
      do_delete
      response.should redirect_to(root_url)
    end

    it "should destroy current owner" do
      do_delete
      Owner.exists?(@owner.id).should be_false
    end

    it "should set flash message" do
      do_delete
      flash[:success].should_not be_nil
    end
  end
end
