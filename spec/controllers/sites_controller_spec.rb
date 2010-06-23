require 'spec_helper'

describe SitesController do
  include Devise::TestHelpers

  integrate_views

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "#create" do
    it "should work" do
      FtpClient.should_receive(:noop)
      post :create, :site => Factory.attributes_for(:site, :owner => nil)

      site = assigns(:site)
      site.new_record?.should be_false
      site.owner.should == @owner
      response.should render_template('create.rjs')
    end

    # it "should complain if there are connection problem" do
    #   FtpClient.should_receive(:noop).and_raise(FtpClientError.new)
    #   post :create, :site => Factory.attributes_for(:site, :owner => nil)
    # 
    #   assigns(:site).new_record?.should be_true
    #   response.should_not render_template(:new)
    # end

    it "should show upgrate popup message if user can't add sites" do
      controller.current_user.stub!(:can_add_site?).and_return(false)
      xhr :post, :create
      response.should have_rjs(:replace_html, 'popup') do
        have_tag "h2#upgrade-message"
      end
    end

    it "should show 'trial period expired' popup message if user can't add sites" do
      controller.current_user.stub!(:trial_period_expired?).and_return(true)
      xhr :post, :create
      response.should have_rjs(:replace_html, 'popup') do
        have_tag "h2#trial-period-expired-message"
      end
    end


  end

  # describe "update" do
  #   it "should complain if there are connection problem" do
  #     site = Factory.create(:site, :login => 'valid', :owner => @owner)
  # 
  #     FtpClient.should_receive(:noop).and_raise(FtpClientError.new)
  #     put :update, :id => site.id, :site => { :login => 'invalid' }
  # 
  #     site.reload.login.should == 'valid'
  #     response.should_not render_template(:edit)
  #   end
  # end
end
