require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :site_id

  def sections
    elements(false).map { |element| element.inner_html }
  end

  def sections=(htmls)
    update_elements(false, htmls) do |element, html| 
      element.inner_html = html
    end
  end

  def images
    elements(true).map { |element| element.attributes['src'] }
  end

  def images=(srcs)
    update_elements(true, srcs) do |img, src| 
      img.attributes['src'] = src
    end
  end

  private

  def document
    @document ||= Hpricot(content) 
  end

  def elements(img)
    (document / '.editfu').select { |e| img == (e.pathname == 'img') }
  end

  def update_elements(img, values)
    i = 0
    elements(img).each do |element|
      yield element, values[i]
      i = i + 1
    end
    self.content = document.to_html
  end
end
