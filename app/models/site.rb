class Site < ActiveRecord::Base
  IMAGES_FOLDER = 'editfu'
  MCE_FOLDER = File.join(IMAGES_FOLDER, 'content')
  SWAP_FOLDER = File.join(IMAGES_FOLDER, 'only')

  belongs_to :owner
  has_many :pages, :dependent => :delete_all

  validates_presence_of :name, :server, :site_root, :site_url, :login, :password
  validates_uniqueness_of :name, :scope => :owner_id
  validates_format_of :site_url, :with => /^(?!http:)/, 
    :message => "Please don't start url with http:// prefix"

  def http_url
    'http://' + site_url
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

