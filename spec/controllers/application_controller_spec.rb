require 'spec_helper'

describe ApplicationController do

  describe "#store_to_cookie" do

    def prepair_fake_session(uri)
      request.stub!(:request_uri).and_return(uri)
      @session = {}
      controller.stub!(:session).and_return(@session)
    end
    
    it "store uri to cookie form 'sites'" do
      ["/sites/1", "/sites/1/pages/1"].each do |u|
        prepair_fake_session(u)
        controller.store_uri_to_cookie
        @session.should include({"sites_uri" => u})
      end
    end
    
    it "store uri to cookie form 'editors'" do
      ["/editors/1"].each do |u|
        prepair_fake_session(u)
        controller.store_uri_to_cookie
        @session.should include({"editors_uri" => u})
      end
    end
    
    it "don't store uri to cookie form some wrong url" do
      wrong_url = ('/' + [('a'..'z').to_a,'/'].flatten.sort_by{rand}.to_s).gsub('/sites', '/notsites').gsub('/editors', '/noteditors')
      prepair_fake_session(wrong_url)
      controller.store_uri_to_cookie
      @session.should be_empty
    end
    
  end
  
  describe "#redirect_from_cookie" do
    
    def prepair_controller(controller_name)
      controller.stub!(:controller_name).and_return(controller_name)
    end    
    
    def prepair_session(controller_name, uri)
      @session = {"#{controller_name}_uri".to_s => uri.to_s}
      stub_session
    end
    
    def stub_session
      @session = @session || {}
      controller.stub!(:session).and_return(@session)
    end

    uris = { :sites => '/sites/1/pages/1', :editors => '/editors/2' }
    uris.each do |controller_name, uri|

      it "should be redirected from cookie" do
        prepair_controller(:sites)
        prepair_session(:sites, uri)
        request.stub!(:request_uri).and_return(controller_name)
        controller.should_receive(:redirect_to).with(uri).and_return(true)

        controller.redirect_from_cookie.should == false
      end

      it "should not be redirected from cookie" do
        prepair_controller(:sites)
        prepair_session(:sites, uri)
        request.stub!(:request_uri).and_return(uri)
        controller.should_not_receive(:redirect_to).with(uri).and_return(true)
        controller.redirect_from_cookie.should == true
      end

      it "should not be redirected without cookie" do
        prepair_controller(:sites)
        stub_session
        request.stub!(:request_uri).and_return(controller_name)
        controller.should_not_receive(:redirect_to).with(uri).and_return(true)
        controller.redirect_from_cookie.should == true
      end
    
    end
    
  end
  
end
