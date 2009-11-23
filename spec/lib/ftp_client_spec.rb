require 'spec_helper'

describe FtpClient do
  before :each do
    @site = Site.new :name => 'mysite', :server => 'ftp.edit-fu.com', 
      :site_root => '/var/ftp/mysite', :login => 'user', :password => 'securekey'
    @site.mkdir
    @ftp = mock('ftp')
  end

  describe 'download' do
    it "should download a remote file" do
      Net::FTP.should_receive(:open).with(@site.server).and_return(@ftp)
      @ftp.should_receive(:login).with(@site.login, @site.password)
      @ftp.should_receive(:passive=).with(true)
      @ftp.should_receive(:chdir).with(@site.site_root)
      @ftp.should_receive(:ls).and_return(
        ['-rw-r--r-- 1 root root Nov 18 2009 home.html']
      )
      @ftp.should_receive(:get).with('home.html', "#{@site.dirname}/home.html")
      @ftp.should_receive(:close)

      FtpClient.download(@site)
    end

    it "should close connection on error" do
      Net::FTP.should_receive(:open).and_return(@ftp)
      @ftp.should_receive(:login).and_raise 'login error'
      @ftp.should_receive(:close)

      begin
        FtpClient.send :open, @site
      rescue
      end
    end

    it "should download a remote folder" do
      FtpClient.stub(:open).and_yield(@ftp)
      @ftp.should_receive(:ls).with().and_return(
        ['drw-r--r-- 1 root root Nov 18 2009 home']
      )
      @ftp.should_receive(:ls).with('home').and_return []

      FtpClient.download(@site)
      File.directory?("#{@site.dirname}/home").should be_true
    end

    it "should download recursively" do
      FtpClient.stub(:open).and_yield(@ftp)
      @ftp.should_receive(:ls).with().and_return(
        ['drw-r--r-- 1 root root Nov 18 2009 home']
      )
      @ftp.should_receive(:ls).with('home').and_return(
        ['-rw-r--r-- 1 root root Nov 18 2009 index.html']
      )
      @ftp.should_receive(:get).with(
        'home/index.html', "#{@site.dirname}/home/index.html"
      )

      FtpClient.download(@site)
    end

    it "should download only html files" do
      FtpClient.stub(:open).and_yield(@ftp)
      @ftp.should_receive(:ls).and_return(
        [
          '-rw-r--r-- 1 root root Nov 18 2009 index.html',
          '-rw-r--r-- 1 root root Nov 18 2009 index.htm',
          '-rw-r--r-- 1 root root Nov 18 2009 index.php'
        ]
      )
      @ftp.should_receive(:get).with('index.html', anything)
      @ftp.should_receive(:get).with('index.htm', anything)

      FtpClient.download(@site)
    end
  end
end

