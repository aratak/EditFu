require 'net/ftp'

class FtpClientError < RuntimeError
end

class FtpClient
  def self.noop(site)
    open site do
    end
  end

  def self.get_page(page)
    open page.site do |f|
      page.content = ""
      f.retrbinary "RETR #{page.path}", Net::FTP::DEFAULT_BLOCKSIZE do |data|
        page.content << data
      end
    end
  end

  def self.put_page(page)
    open page.site do |f|
      f.storbinary "STOR #{page.path}", 
        StringIO.new(page.content), Net::FTP::DEFAULT_BLOCKSIZE
    end
  end

  def self.put_image(site, local_path, remote_name)
    open site do |f|
      if f.ls(Site::IMAGES_FOLDER).empty?
        f.mkdir Site::IMAGES_FOLDER
      end
      f.put local_path, Site::IMAGES_FOLDER + '/' + remote_name
    end
    remote_name
  end

  def self.ls(site, folder)
    # FTP doesn't raise FTPPermError on ls - we should chdir to get it.
    open site, folder do |f|
      f.ls.map do |line|
        line =~ /(\S+)\s+(\S+\s+){7}(.*)/
        { :name => $3, :type => $1.start_with?('d') ? :folder : :file }
      end
    end
  end

  private

  def self.open(site, dir = site.site_root)
    begin
      f = Net::FTP.open site.server
    rescue 
      raise FtpClientError, "Can't connect to FTP server - check domain name."
    end

    begin
      f.login site.login, site.password
      f.passive = true
      f.chdir dir

      yield f if block_given?
    rescue Net::FTPError => e
      raise translate_ftp_error(e)
    ensure
      f.close
    end
  end

  def self.translate_ftp_error(e)
    code = e.message[0, 3]
    message = e.message[4, e.message.length]
    FtpClientError.new(message)
  end
end
