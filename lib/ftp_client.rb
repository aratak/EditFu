require 'net/ftp'

class FtpClient
  def self.noop(site)
    open site do
    end
  end

  def self.get(page)
    open page.site do |f|
      page.content = ""
      f.retrbinary "RETR #{page.path}", Net::FTP::DEFAULT_BLOCKSIZE do |data|
        page.content << data
      end
    end
  end

  def self.put(page)
    open page.site do |f|
      f.storbinary "STOR #{page.path}", 
        StringIO.new(page.content), Net::FTP::DEFAULT_BLOCKSIZE
    end
  end

  private

  def self.open(site)
    f = Net::FTP.open site.server
    begin
      f.login site.login, site.password
      f.passive = true
      f.chdir site.site_root

      yield f if block_given?
    ensure
      f.close
    end
  end
end
