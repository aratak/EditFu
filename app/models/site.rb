class Site < ActiveRecord::Base
  has_many :pages

  validates_presence_of :name, :server, :site_root, :login, :password
  validates_uniqueness_of :name

  def dirname
    File.join SITES_DIR, name
  end

  def mkdir
    FileUtils.rm_rf dirname
    FileUtils.mkdir_p dirname
  end

  def download
    mkdir
    FtpClient.download self
    create_pages
  end

  def validate_on_create
    begin
      FtpClient.noop(self)
    rescue Exception => e
      errors.add_to_base "Can't connect to FTP server."
    end
  end

  private

  def create_pages(path=dirname)
    result = true
    Dir.new(path).each do |filename|
      unless filename == '.' or filename == '..'
        filepath = File.join(path, filename)
        if File.directory?(filepath)
          empty_file = create_pages filepath
        else
          relpath = filepath[dirname.length + 1, filepath.length]
          page = Page.new(:site => self, :path => relpath)
          empty_file = page.sections.empty?
          pages << page unless empty_file
        end
        FileUtils.rm_rf filepath if empty_file
        result &&= empty_file
      end
    end
    result
  end
end
