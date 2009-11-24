require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site

  def open(mode='r', &block)
    filename = File.join site.dirname, path
    File.open filename, mode, &block
  end

  def sections
    open do |file|
      (Hpricot(file) / '.editfu').map { |element| element.inner_html }
    end
  end
end
