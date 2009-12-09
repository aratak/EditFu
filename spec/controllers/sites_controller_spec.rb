require 'spec_helper'

describe SitesController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "create" do
    it "should work" do
      FtpClient.should_receive(:noop)
      post :create, :site => Factory.attributes_for(:site, :owner => nil)

      site = assigns(:site)
      site.new_record?.should be_false
      site.owner.should == @owner
      response.should redirect_to(site_path(site))
    end

    it "should complain if there are connection problem" do
      message = 'some message'
      FtpClient.should_receive(:noop).and_raise(FtpClientError.new(message))
      post :create, :site => Factory.attributes_for(:site, :owner => nil)

      assigns(:site).new_record?.should be_true
      response.should render_template(:new)
    end
  end
end
