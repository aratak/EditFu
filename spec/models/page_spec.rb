require 'spec_helper'

describe Page do
  before :each do
    @page = Factory.create(:page)
  end

  describe "sections" do
    it "should get page content from remote server and cache it" do
      @page.content = <<-EOS
        <html>
          <body>
            <h1 class='editfu'>Hello, <b>World</b>!</h1>
          </body>
        </html>
      EOS

      @page.sections.should == ['Hello, <b>World</b>!']
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

  describe "#images" do
    it "should return a list of tagged images from a remote server" do
      @page.content = <<-EOS
        <html>
          <body>
            <img src='photo.gif' class='editfu'>
            <div>
              <img src='images/banner.png' class='editfu'>
            </div>
          </body>
        </html>
      EOS

      @page.images.should == ['photo.gif', 'images/banner.png']
    end
  end
end
