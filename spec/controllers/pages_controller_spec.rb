require 'spec_helper'

describe PagesController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "#create" do
    it "should redirect to new if user can't add pages" do
      controller.current_user.stub!(:can_add_page?).and_return(false)
      post :create
      response.should redirect_to(:action => :new)
    end
  end
end