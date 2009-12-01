require 'spec_helper'

describe Site do
  before :each do
    @site = Site.new :name => 'mysite', 
      :server => 'ftp.edit-fu.com', :site_root => '/var/ftp/mysite',
      :login => 'user', :password => 'securekey'
  end

  describe 'save' do
    it "should check FTP connection" do
      FtpClient.should_receive(:noop).with(@site)
      @site.save
    end

    it "should fail if there are problems in FTP" do
      FtpClient.should_receive(:noop).and_raise(FtpClientError.new)
      @site.save.should be_false
    end
  end
end
