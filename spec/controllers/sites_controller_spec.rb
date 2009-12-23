require 'spec_helper'

describe SitesController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  #describe "#new" do
  #  it "should not create new site when trial period expired" do
  #    controller.current_user.stub!(:trial_period_expired?).and_return(true)
  #    get :new
  #    response.should redirect_to(:action => :show)
  #  end
  #end

  describe "#create" do
    it "should work" do
      FtpClient.should_receive(:noop)
      post :create, :site => Factory.attributes_for(:site, :owner => nil)

      site = assigns(:site)
      site.new_record?.should be_false
      site.owner.should == @owner
      response.should redirect_to(site_path(site))
    end

    it "should complain if there are connection problem" do
      FtpClient.should_receive(:noop).and_raise(FtpClientError.new)
      post :create, :site => Factory.attributes_for(:site, :owner => nil)

      assigns(:site).new_record?.should be_true
      response.should render_template(:new)
    end

    it "should redirect to new if user can't add sites" do
      controller.current_user.stub!(:can_add_site?).and_return(false)
      post :create
      response.should redirect_to(:action => :new)
    end
  end

  describe "update" do
    it "should complain if there are connection problem" do
      site = Factory.create(:site, :login => 'valid', :owner => @owner)

      FtpClient.should_receive(:noop).and_raise(FtpClientError.new)
      put :update, :id => site.id, :site => { :login => 'invalid' }

      site.reload.login.should == 'valid'
      response.should render_template(:edit)
    end
  end
end
