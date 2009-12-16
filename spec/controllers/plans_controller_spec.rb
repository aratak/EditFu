require 'spec_helper'

describe PlansController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "#edit" do
    it "should be successful" do
      get :edit
      response.should be_success
    end
  end

  describe "#update" do
    it "should redirect to preferences url" do
      put :update, :owner => {}
      response.should redirect_to(preferences_url)
    end
  end
end
