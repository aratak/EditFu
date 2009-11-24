require 'hpricot'

class Page < ActiveRecord::Base
  belongs_to :site

  def local_name
    File.join site.dirname, path
  end

  def open(mode='r', &block)
    File.open local_name, mode, &block
  end

  def sections
    open do |file|
      (read_document / '.editfu').map { |element| element.inner_html }
    end
  end

  def sections=(secs)
    i = 0
    document = read_document
    open 'w+' do |file|
      (document / '.editfu').each do |element| 
        element.inner_html = secs[i]
        i = i + 1
      end
      file << document.to_html
    end

    FtpClient.put_page self
  end

  private

  def read_document
    open do |file|
      Hpricot(file)
    end
  end
end
