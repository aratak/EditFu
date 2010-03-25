require 'spec_helper'

describe Site do
  before :each do
    @site = Factory.create(:site)
  end

  describe 'check_connection' do
    it "should check FTP connection" do
      FtpClient.should_receive(:noop).with(@site)

      @site.check_connection.should be_true
      @site.errors.should be_empty
    end

    it "should fail if there are problems in FTP" do
      FtpClient.should_receive(:noop).and_raise(FtpClientError.new)

      @site.check_connection.should be_false
      @site.errors.should_not be_empty
    end
  end

  describe "#destroy" do
    before(:each) do
      2.times do
        Factory(:page, :site => @site)
      end
    end

    it "should destroy pages of this site" do
      @site.destroy
      Page.find_all_by_site_id(@site.id).should == []
    end
  end

  describe "#root_folders" do
    it "should return a list of site_root folders" do
      @site.site_root = '/home/peter/site'
      @site.root_folders.should == ['home', 'peter', 'site']
    end
  end

  describe "before_save" do
    it "should strip spaces and remove trailing slash" do
      Factory.create(:site, :site_url => ' www.yandex.ru/ ').site_url.should == 
        'www.yandex.ru'
    end
  end

  describe "validations" do
    it "should reject site_url with starting http prefix" do
      @site.site_url = 'http://www.microsoft.com'
      @site.save
      @site.errors.on(:site_url).should_not be_blank
    end
  end
end
