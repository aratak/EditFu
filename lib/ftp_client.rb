require 'net/ftp'

class FtpClientError < RuntimeError
  attr_reader :code

  def initialize(message = nil, code = nil)
    super message
    @code = code
  end
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
      # Some FTP servers raise error on ls 'not-existent-folder-name' 
      # and some simply return empty list
      begin
        images = list(f, remote_dir).map { |file| file[:name] }
      rescue Net::FTPError
      end

      if images.blank?
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
      list(f)
    end
  end

  def self.tree(site, folder)
    result = nil

    open site, File::SEPARATOR do |f|
      while folder != File::SEPARATOR do
        children = result
        folder, child = File.split(folder)
        result = list(f, folder)

        child_file = result.find { |file| file[:name] == child }
        if child_file && children
          child_file[:children] = children
        end
      end
    end

    result
  end

  private

  def self.open(site, dir = site.site_root)
    begin
      f = Net::FTP.open site.server
    rescue 
      raise FtpClientError, 
        "Your FTP server address is incorrect. " +
        "Please double check that it is correct and try again."
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
    end.sort do |a, b|
      a[:name] <=> b[:name] && b[:type].to_s <=> a[:type].to_s
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
    message = 
      if code == '530'
        'FTP login was incorrect. Please check your username/password and try again.'
      else
        e.message[4, e.message.length].strip
      end
    FtpClientError.new(message, code)
  end
end
