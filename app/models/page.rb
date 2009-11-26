require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site

  def sections
    FtpClient.get(self)

    (Hpricot(content) / '.editfu').map do |element|
      element.inner_html
    end
  end

  def sections=(sections)
    i = 0
    document = Hpricot(content) 
    (document / '.editfu').map do |element|
      element.inner_html = sections[i]
      i = i + 1
    end
    self.content = document.to_html

    FtpClient.put(self)
  end
end
