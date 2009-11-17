require 'spec_helper'

describe Site do
  before :each do
    FileUtils.rm_rf Site::SITES_DIR
    @site = Site.new :name => 'mysite', 
      :server => 'ftp.edit-fu.com', :site_root => '/var/ftp/mysite',
      :login => 'user', :password => 'securekey'
    @site.mkdir
  end

  it "should download content and create page records on init" do
    FtpClient.should_receive(:download).with(@site).and_return do
      File.open File.join(@site.dirname, 'home.html'), 'w+' do |file|
        file.write "<html><body class='edit-fu'></body></html>"
      end
    end

    @site.init
    @site.pages.first.path.should == 'home.html'
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
