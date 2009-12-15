require 'spec_helper'

describe EditorsController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "#create" do
    it "should redirect to new if user can't add editors" do
      controller.current_user.stub!(:can_add_editor?).and_return(false)
      post :create
      response.should redirect_to(:action => :new)
    end
  end
end