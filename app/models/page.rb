require 'hpricot'

class Page < ActiveRecord::Base
  IMAGE_ATTRIBUTES = ['src', 'alt']

  belongs_to :site, :autosave => true, :validate => true
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :site_id
  validate :permission

  named_scope :enabled, :conditions => { :enabled => true }

  def owner
    site.owner
  end
  
  def permission
    errors.add_to_base "can't add anymore" unless owner.can_add_page?
  end

  def url
    File.join(site.http_url, path)
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
    elements(true).map do |element| 
      result = {}
      IMAGE_ATTRIBUTES.each { |k| result[k] = element[k] || '' }
      result
    end
  end
  
  def empty?
    sections.empty? && images.empty?
  end

  def images=(elements)
    update_elements(true, elements) do |img, attributes| 
      attributes.each { |k,v| img.attributes[k.to_s] = v }
    end
  end

  def has_suspicious_sections?
    elements(false).any? { |e| !['div', 'span'].include?(e.pathname) }
  end

  def html_valid?
    ((document / '.editfu') - nodes).empty?
  end


  protected

  def before_save
    self.path = self.path.strip.sub(/^\//, '').sub(/\/$/, '')
  end

  private

  def document
    @document ||= Hpricot(content) 
  end

  def nodes
    (document / 'div.editfu, img.editfu')
  end

  def elements(img)
    nodes.select do |e| 
      !nested_node?(e, nodes) && (e.pathname == 'img') == img
    end
  end

  def nested_node?(node, nodes)
    par = node.parent
    while par do
      return true if nodes.include?(par)
      par = par.parent
    end
  end

  def update_elements(img, values)
    elements(img).each_with_index do |element, index|
      yield element, values[index]
    end
    self.content = document.to_html
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

