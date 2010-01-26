require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :site_id

  def sections
    map_sections do |element|
      element.inner_html
    end
  end

  def sections=(sections)
    i = 0
    map_sections do |element|
      element.inner_html = sections[i]
      i = i + 1
    end
    self.content = document.to_html
  end

  def images
    map_images do |element|
      element.attributes['src']
    end
  end

  private

  def document
    @document ||= Hpricot(content) 
  end

  def map_sections
    (document / '.editfu').map { |element| yield element }
  end

  def map_images
    (document / 'img.editfu').map { |element| yield element }
  end
end
