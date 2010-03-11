require 'spec_helper'

describe PagesController do
  include Devise::TestHelpers

  integrate_views

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "#create" do
    it "should show upgrate popup message if user can't add pages" do
      controller.current_user.stub!(:can_add_page?).and_return(false)

      xhr :post, :create, :site_id => 1
      response.should have_rjs(:replace_html, 'popup') do
        have_tag "h2#upgrade-message"
      end
    end
  end
end