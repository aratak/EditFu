require 'spec_helper'

describe FtpClient do
  describe 'download' do
    it "should download a remote file" do
      site = Site.new :name => 'mysite', :server => 'ftp.edit-fu.com', 
        :site_root => '/var/ftp/mysite', :login => 'user', :password => 'securekey'

      ftp = mock('ftp')
      Net::FTP.should_receive(:open).with(site.server).and_return(ftp)
      ftp.should_receive(:login).with(site.login, site.password)
      ftp.should_receive(:passive=).with(true)
      ftp.should_receive(:chdir).with(site.site_root)
      ftp.should_receive(:ls).and_return(
        '-rw-r--r-- 1 root root Nov 18 2009 home.html'
      )
      ftp.should_receive(:get).with('home.html', "#{site.dirname}/home.html")
      ftp.should_receive(:close)

      FtpClient.download(site)
    end
  end
end

