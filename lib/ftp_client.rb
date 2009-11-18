require 'net/ftp'

class FtpClient
  def self.download(site)
    open site do |f| 
      f.ls.each do |file|
        file_name = file.split(/\s+/).last
        f.get file_name, File.join(site.dirname, file_name)
      end
    end
  end

  private

  def self.open(site, &block)
    f = Net::FTP.open site.server
    f.login site.login, site.password
    f.passive = true
    f.chdir site.site_root

    yield f
    f.close
  end
end
