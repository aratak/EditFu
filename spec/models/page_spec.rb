require 'spec_helper'

describe Page do
  before :each do
    @site = Site.new :name => 'mysite'
    @page = Page.new :site => @site, :path => 'home.html'
  end

  describe "sections" do
    it "should get page content from remote server and cache it" do
      FtpClient.should_receive(:get).with(@page).and_return do
        @page.content = <<-EOS
          <html>
            <body>
              <h1 class='editfu'>Hello, <b>World</b>!</h1>
            </body>
          </html>
        EOS
      end

      sections = @page.sections
      sections.first.should == 'Hello, <b>World</b>!'
      sections.size.should == 1
    end
  end

  describe "sections=" do
    it "should put page content to remote server" do
      @page.content = <<-EOS
        <html>
          <body>
            <h1 class="editfu">Hello, World!</h1>
          </body>
        </html>
      EOS
      FtpClient.should_receive(:put).with(@page)

      @page.sections = ['Good-by, blue sky...']
      @page.content.should == <<-EOS
        <html>
          <body>
            <h1 class="editfu">Good-by, blue sky...</h1>
          </body>
        </html>
      EOS
    end
  end
end
