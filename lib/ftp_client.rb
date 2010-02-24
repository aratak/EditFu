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

  def self.put_image(site, local_path, remote_path)
    remote_dir, remote_name = File.split(remote_path)

    open site do |f|
      images = list(f, remote_dir).map { |file| file[:name] }
      if images.empty?
        mkdir_p f, remote_dir
      else
        remote_name = generate_image_name(remote_name, images)
      end
      f.put local_path, File.join(remote_dir, remote_name)
    end
    remote_name
  end

  def self.ls(site, folder)
    # FTP doesn't raise FTPPermError on ls - we should chdir to get it.
    open site, folder do |f|
      list(f).sort do |a, b|
        a[:name] <=> b[:name] && b[:type].to_s <=> a[:type].to_s
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

  def self.list(ftp, *args) 
    ftp.ls(*args).map do |line|
      line =~ /(\S+)\s+(\S+\s+){7}(.*)/
      { :name => $3, :type => $1.start_with?('d') ? :folder : :file }
    end
  end

  def self.generate_image_name(original_name, existing_names)
    original_name =~ /^([^.]*)(\.?.*)$/
    basename, suffix = $1, $2
    revisions = existing_names.map do |n| 
      n =~ /^#{basename}(\d*)#{suffix}$/ 
      $1
    end.compact.map { |n| n.blank? ? 1 : n.to_i }
    
    return original_name if revisions.empty?
    rev = revisions.max + 1
    basename + rev.to_s + suffix
  end

  def self.mkdir_p(ftp, path)
    dir = nil
    path.split(File::SEPARATOR).each do |name|
      dir = dir.nil? ? name : File.join(dir, name)
      begin
        ftp.mkdir dir
      rescue Net::FTPError
      end
    end
  end

  def self.translate_ftp_error(e)
    code = e.message[0, 3]
    message = e.message[4, e.message.length]
    FtpClientError.new(message)
  end
end
