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

    it "should skip nested sections" do
      @page.content = <<-EOS
        <html>
          <body>
            <p class='editfu'><b class='editfu'>Hello</b></p>
          </body>
        </html>
      EOS

      @page.sections.should == ['<b class="editfu">Hello</b>']
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
            <img src='photo.gif' alt='Photo' class='editfu'>
            <div>
              <img src='images/banner.png' class='editfu'>
            </div>
          </body>
        </html>
      EOS

      @page.images.should == [
        { 'src' => 'photo.gif', 'alt' => 'Photo' }, 
        { 'src' => 'images/banner.png', 'alt' => '' }
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

  describe "has_suspicious_sections?" do
    it "should be true if page contains 'p' section" do
      @page.content = <<-EOS
        <html>
          <body>
            <p class="editfu"></p>
          </body>
        </html>
      EOS

      @page.has_suspicious_sections?.should be_true
    end

    it "should be false if page contains only 'div' and 'span' sections" do
      @page.content = <<-EOS
        <html>
          <body>
            <div class="editfu"></div>
            <span class="editfu"></span>
          </body>
        </html>
      EOS

      @page.has_suspicious_sections?.should be_false
    end

    it "should ignore non-section tags" do
      @page.content = <<-EOS
        <html>
          <body>
            <p></p>
            <div class="editfu"></div>
          </body>
        </html>
      EOS

      @page.has_suspicious_sections?.should be_false
    end

    it "should ignore nested sections" do
      @page.content = <<-EOS
        <html>
          <body>
            <div class="editfu"><p class="editfu"></p></div>
          </body>
        </html>
      EOS

      @page.has_suspicious_sections?.should be_false
    end
  end

  describe "before_save" do
    it "should strip path and remove start and end slashes" do
      Factory.create(:page, :path => ' /index.html/ ').path.should == 
        'index.html'
    end
  end
  
  
  describe "multicreate" do
    
    it "#deny" do
        owner = mock_model(Owner, :can_add_page? => false)
        site = Factory(:site, :owner => owner)
        page = Page.new(:path => "index.html", :site => site)
        
        page.valid?.should be_false
        page.errors.should_not be_empty
    end
    
    it "#allow" do
        owner = mock_model(Owner, :can_add_page? => true)
        site = Factory(:site, :owner => owner)
        page = Page.new(:path => "index.html", :site => site)
        
        page.valid?.should be_true
    end
    
    
    
  end
  
end

# == Schema Information
#
# Table name: pages
#
#  id      :integer(4)      not null, primary key
#  site_id :integer(4)      not null
#  path    :string(255)     not null
#  content :text
#  enabled :boolean(1)      default(TRUE), not null
#

