require 'spec_helper'

describe Page do
  it "should expose section from file" do
    site = Site.new :name => 'mysite'
    site.mkdir
    page = Page.new :site => site, :path => 'home.html'

    page.open 'w+' do |file|
      file.write <<-EOF
        <html>
          <body>
            <h1 class='edit-fu'>Hello, <b>World</b>!</h1>
          </body>
        </html>
      EOF
    end

    page.sections.first.should == 'Hello, <b>World</b>!'
    page.sections.size.should == 1
  end
end
