require 'spec_helper'

describe Page do
  before :each do
    @site = Site.new :name => 'mysite'
    @site.mkdir
    @page = Page.new :site => @site, :path => 'home.html'

    @page.open 'w+' do |file|
      file.write <<-EOF
        <html>
          <body>
            <h1 class='editfu'>Hello, <b>World</b>!</h1>
          </body>
        </html>
      EOF
    end
  end

  describe "sections" do
    it "should expose section from file" do
      @page.sections.first.should == 'Hello, <b>World</b>!'
      @page.sections.size.should == 1
    end
  end

  describe "sections=" do
    it "should update local cache and remote file" do
      FtpClient.should_receive(:put_page).with(@page)
      new_section = 'Good-by, blue sky...'

      @page.sections = [new_section]
      @page.sections.first.should == new_section
    end
  end
end
