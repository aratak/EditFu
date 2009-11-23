class Site < ActiveRecord::Base
  SITES_DIR = 'tmp/sites'
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

  def validate_on_create
    mkdir
    begin
      FtpClient.download self
    rescue
      errors.add_to_base "Can't download files from specified server."
    end
  end

  def after_create
    create_pages
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
