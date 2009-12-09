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
end
