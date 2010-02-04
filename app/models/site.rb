class Site < ActiveRecord::Base
  IMAGES_FOLDER = 'editfu'

  belongs_to :owner
  has_many :pages, :dependent => :delete_all

  validates_presence_of :name, :server, :site_root, :site_url, :login, :password
  validates_uniqueness_of :name, :scope => :owner_id

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
end
