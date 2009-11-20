require 'spec_helper'

describe Site do
  before :each do
    @site = Site.new :name => 'mysite', 
      :server => 'ftp.edit-fu.com', :site_root => '/var/ftp/mysite',
      :login => 'user', :password => 'securekey'
  end

  describe 'save' do
    it "should download content and create page records" do
      FileUtils.rm_rf @site.dirname

      FtpClient.should_receive(:download).with(@site).and_return do
        File.open File.join(@site.dirname, 'home.html'), 'w+' do |file|
          file.write "<html><body class='edit-fu'></body></html>"
        end
      end

      @site.save
      @site.pages.first.path.should == 'home.html'
    end

    it "should fail if there are problems in FTP" do
      FtpClient.should_receive(:download).and_raise('error')
      
      @site.save.should be_false
    end
  end

  describe 'create_pages' do
    before :each do
      @site.mkdir
    end

    it "should not create page without sections" do
      File.open File.join(@site.dirname, 'home.html'), 'w+' do |file|
        file.write '<html><body></body></html>'
      end

      @site.send :create_pages
      @site.pages.should be_empty
    end

    it "should recursively traverse directories for pages" do
      FileUtils.mkdir_p File.join(@site.dirname, 'home')
      File.open File.join(@site.dirname, 'home/peter.html'), 'w+' do |file|
        file.write "<html><body class='edit-fu'></body></html>"
      end

      @site.send :create_pages
      @site.pages.first.path.should == 'home/peter.html'
    end

    it "should ignore unparseable files" do
      File.open File.join(@site.dirname, 'home.html'), 'w+' do |file|
        file.write '<html><body></nosuchelement>'
      end

      @site.send :create_pages
      @site.pages.should be_empty
    end
  end
end
