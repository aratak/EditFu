require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :site_id

  def sections
    FtpClient.get_page(self)

    map_sections(document) do |element|
      element.inner_html
    end
  end

  def sections=(sections)
    i = 0
    document = Hpricot(content) 
    map_sections(document) do |element|
      element.inner_html = sections[i]
      i = i + 1
    end
    self.content = document.to_html

    FtpClient.put_page(self)
  end

  private

  def document
    Hpricot(content) 
  end

  def map_sections(document)
    (document / '.editfu').map { |element| yield element }
  end
end
