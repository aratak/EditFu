require 'spec_helper'

describe Page do
  before :each do
    @page = Factory.create(:page)
  end

  describe "sections" do
    it "should parse page html content" do
      @page.content = <<-EOS
        <html>
          <body>
            <h1 class='editfu'>Hello, <b>World</b>!</h1>
          </body>
        </html>
      EOS

      @page.sections.should == ['Hello, <b>World</b>!']
    end

    it "should skip tagged image elements" do
      @page.content = <<-EOS
        <html>
          <body>
            <h1 class='editfu'>Hello</h1>
            <img class='editfu' src='banner.png'>
          </body>
        </html>
      EOS

      @page.sections.should == ['Hello']
    end
  end

  describe "sections=" do
    it "should merge updated sections into page html" do
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
    it "should return a list of tagged images from a page" do
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

      @page.images.should == [
        { :src => 'photo.gif' }, { :src => 'images/banner.png' }
      ]
    end
  end

  describe "#images=" do
    it "should merge updated srcs into images" do
      @page.content = <<-EOS
        <html>
          <body>
            <img class="editfu" src="banner.png">
          </body>
        </html>
      EOS

      @page.images = [ { :src => 'photo.gif'} ]
      @page.content.should == <<-EOS
        <html>
          <body>
            <img class="editfu" src="photo.gif" />
          </body>
        </html>
      EOS
    end
  end
end
