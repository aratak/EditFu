require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :site_id

  def url
    site.site_url + '/' + path
  end

  def sections
    elements(false).map { |element| element.inner_html }
  end

  def sections=(htmls)
    update_elements(false, htmls) do |element, html| 
      element.inner_html = html
    end
  end

  def images
    elements(true).map { |element| { :src => element.attributes['src'] } }
  end

  def images=(elements)
    update_elements(true, elements) do |img, attributes| 
      attributes.each { |k,v| img.attributes[k.to_s] = v }
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
    elements(img).each_with_index do |element, index|
      yield element, values[index]
    end
    self.content = document.to_html
  end
end
