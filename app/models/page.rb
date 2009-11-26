require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site

  def sections
    FtpClient.get(self)

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

    FtpClient.put(self)
  end

  private

  def document
    Hpricot(content) 
  end

  def map_sections(document)
    (document / '.editfu').map { |element| yield element }
  end
end
