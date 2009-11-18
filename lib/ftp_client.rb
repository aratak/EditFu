require 'net/ftp'

class FtpClient
  def self.download(site)
    open site do |f| 
      cp_r f, nil, site.dirname
    end
  end

  private

  def self.cp_r(ftp, remote, local)
    ls_args = []
    ls_args << remote if remote

    ftp.ls(*ls_args).each do |file|
      opts = file.split(/\s+/)
      mode = opts.first
      name = opts.last

      file_local = File.join(local, name)
      file_remote = remote ? File.join(remote, name) : name

      if mode.match(/^d/)
        Dir.mkdir file_local
        cp_r ftp, file_remote, file_local
      else
        ftp.get file_remote, file_local
      end
    end
  end

  def self.open(site, &block)
    f = Net::FTP.open site.server
    begin
      f.login site.login, site.password
      f.passive = true
      f.chdir site.site_root

      yield f
    ensure
      f.close
    end
  end
end
