class Site < ActiveRecord::Base
  IMAGES_FOLDER = 'editfu'
  MCE_FOLDER = File.join(IMAGES_FOLDER, 'content')
  SWAP_FOLDER = File.join(IMAGES_FOLDER, 'swap')

  attr_accessor :should_add_pages

  belongs_to :owner #, :autosave => true, :validate => true
  has_many :pages, :dependent => :delete_all

  validates_presence_of :name, :server, :site_root, :site_url, :login, :password
  validates_uniqueness_of :name, :scope => :owner_id
  validates_format_of :site_url, :with => /^(?!http:)/, 
    :message => "Please don't start url with http:// prefix"

  after_save :create_pages

  def http_url
    'http://' + site_url
  end

  def should_add_pages
    @should_add_pages.nil? || @should_add_pages
  end

  def should_add_pages=(val)
    @should_add_pages = ["true", true, "1", 1, "on"].include?(val)
  end

  def create_pages
    return nil unless @should_add_pages
    list_files.each do |file_path|
      pages.create :path => file_path
    end
  end

  def validate_and_save
    if valid? && check_connection
      save(false)
    end
  end

  def check_connection
    begin
      FtpClient.noop(self)
    rescue FtpClientError => e
      errors.add_to_base e.message
    end
    errors.empty?
  end

  def root_folders
    site_root.split('/').select { |i| !i.blank? }
  end

  protected

  def before_save
    self.site_url = self.site_url.strip.sub(/\/$/, '')
  end

  private

  def list_files path=nil
    path ||= self.site_root
    begin
      ll = FtpClient.ls(self, path)
      all_folders = ll.select { |e| e[:type] == :folder }
      files_inside_folders = all_folders.map{ |fo| list_files("#{path}/#{fo[:name]}") }.flatten
      all_files = (ll - all_folders).map{ |f| "#{path}/#{f[:name]}" } + files_inside_folders
      html_files = all_files.select { |f| f.scan(/(.*\.html?)$/).any? }
      html_files.map { |f| f.gsub("#{self.site_root}/", "") }
    rescue FtpClientError => e
      errors.add_to_base e.message
    end
  end

end

# == Schema Information
#
# Table name: sites
#
#  id        :integer(4)      not null, primary key
#  name      :string(255)     not null
#  server    :string(255)     not null
#  site_root :string(255)     not null
#  login     :string(255)
#  password  :string(255)
#  owner_id  :integer(4)
#  site_url  :string(50)
#

