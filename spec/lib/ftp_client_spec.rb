require 'spec_helper'

describe FtpClient do
  before :each do
    @site = Factory.create(:site)
    @page = Factory.create(:page, :site => @site)
    @ftp = mock('ftp')
  end

  describe "noop" do
    it "should call open for testing FTP connection" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      FtpClient.noop(@site)
    end
  end

  describe "get_page" do
    it "should download a remote file" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      @ftp.should_receive(:retrbinary).
        with("RETR #{@page.path}", Net::FTP::DEFAULT_BLOCKSIZE).
        and_yield('first...').and_yield('and second')

      FtpClient.get_page(@page)
      @page.content.should == 'first...and second'
    end
  end

  describe "put_page" do
    it "should upload content to remote file" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      @ftp.should_receive(:storbinary).with(
        "STOR #{@page.path}", an_instance_of(StringIO), Net::FTP::DEFAULT_BLOCKSIZE
      ).and_return do |cmd, file, blocksize|
        file.string.should == @page.content
      end

      @page.content = 'some html text'
      FtpClient.put_page(@page)
    end
  end

  describe "put_image" do
    before :each do 
      @mce_photo = "#{Site::MCE_FOLDER}/photo.gif"
    end

    it "should check images folder exists and upload image file" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      @ftp.should_receive(:ls).with(Site::MCE_FOLDER).and_return [
        "drwxr-xr-x    5 1003     1003         4096 Dec 11 11:31 image.png"
      ]
      @ftp.should_receive(:put).with('/tmp/1.gif', @mce_photo)

      FtpClient.put_image(@site, '/tmp/1.gif', @mce_photo).should == 'photo.gif'
    end

    it "should create image folders if they don't exist yet" do
      FtpClient.should_receive(:open).and_yield(@ftp)
      @ftp.should_receive(:ls).and_return []
      @ftp.should_receive(:mkdir).with(Site::IMAGES_FOLDER)
      @ftp.should_receive(:mkdir).with(Site::MCE_FOLDER)
      @ftp.should_receive(:put)

      FtpClient.put_image(@site, '/tmp/1.gif', @mce_photo)
    end

    it "should skip mkdir errors in hope it was caused by empty image folder existence" do
      FtpClient.should_receive(:open).and_yield(@ftp)
      @ftp.should_receive(:ls).and_return []
      @ftp.should_receive(:mkdir).and_raise(Net::FTPError)
      @ftp.should_receive(:mkdir)
      @ftp.should_receive(:put)

      FtpClient.put_image(@site, '/tmp/1.gif', @mce_photo)
    end
    
    it "should add index to basename if file already exists" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      @ftp.should_receive(:ls).and_return [
        "drwxr-xr-x    5 1003     1003         4096 Dec 11 11:31 photo.gif"
      ]
      @ftp.should_receive(:put)

      FtpClient.put_image(@site, '/tmp/1.gif', @mce_photo).should == 'photo2.gif'
    end

    it "should iterate over existing filenames during image name generation" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      @ftp.should_receive(:ls).and_return [
        "drwxr-xr-x    5 1003     1003         4096 Dec 11 11:31 photo.gif",
        "drwxr-xr-x    5 1003     1003         4096 Dec 11 11:31 photo2.gif"
      ]
      @ftp.should_receive(:put)

      FtpClient.put_image(@site, '/tmp/1.gif', @mce_photo).should == 'photo3.gif'
    end

    it "should use max revision name in name generation" do
      FtpClient.should_receive(:open).with(@site).and_yield(@ftp)
      @ftp.should_receive(:ls).and_return [
        "drwxr-xr-x    5 1003     1003         4096 Dec 11 11:31 photo100.gif"
      ]
      @ftp.should_receive(:put)

      FtpClient.put_image(@site, '/tmp/1.gif', @mce_photo).should == 'photo101.gif'
    end
  end

  describe "ls" do
    it "show issue FTP 'ls' command and parse its output" do
      folder = '/home/peter'
      FtpClient.should_receive(:open).with(@site, folder).and_yield(@ftp)

      @ftp.should_receive(:ls).with().and_return [
        "drwxr-xr-x    5 1003     1003         4096 Dec 11 11:31 peter",
        "drwxr-xr-x    5 1002     1002         4096 Nov 20 12:31 james",
        "drwxr-xr-x    2 0        65534        4096 Nov 19 15:28 jane",
        "-rw-r--r--    2 0        65534        4096 Nov 19 15:28 README"
      ]

      FtpClient.ls(@site, folder).should == [
        { :name => 'peter', :type => :folder },
        { :name => 'james', :type => :folder },
        { :name => 'jane', :type => :folder }, 
        { :name => 'README', :type => :file }
      ]
    end
  end

  describe "open" do
    it "should issue all required commands" do
      Net::FTP.should_receive(:open).with(@site.server).and_return(@ftp)
      @ftp.should_receive(:login).with(@site.login, @site.password)
      @ftp.should_receive(:passive=).with(true)
      @ftp.should_receive(:chdir).with(@site.site_root)
      @ftp.should_receive(:close)

      FtpClient.send :open, @site
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

    it "should cut off codes from ftp error messages" do
      Net::FTP.should_receive(:open).and_return(@ftp)
      @ftp.should_receive(:login).and_raise(
        Net::FTPError.new('530 Login incorrect.')
      )
      @ftp.should_receive(:close)

      lambda do
        FtpClient.send :open, @site
      end.should raise_error(FtpClientError, 'Login incorrect.')
    end

    it "should translate open socket error message" do
      Net::FTP.should_receive(:open).and_raise(SocketError.new)

      lambda do
        FtpClient.send :open, @site
      end.should raise_error(FtpClientError, "Can't connect to FTP server - check domain name.")
    end
  end
end

