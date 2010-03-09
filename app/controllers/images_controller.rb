class ImagesController < ApplicationController
  before_filter :authenticate_user!
  layout 'popup'

  def new
    find_site

    begin
      dir = File.join(@site.site_root, type_dir)
      @images = FtpClient.ls(@site, dir).map { |f| f[:name] }
    rescue
      @images = []
    end
  end

  def create
    begin
      image = params[:image]
      remote_path = File.join(type_dir, image.original_filename)
      name = FtpClient.put_image(find_site, image.path, remote_path)
      render :partial => 'show', :locals => { :name => name }
    rescue Exception => e
      logger.warn 'Got exception in image upload: ' + e.message
      render :nothing => true
    end
  end

  private

  def type_dir
    @type = File.basename(params[:type])
    @type_dir = File.join Site::IMAGES_FOLDER, @type
  end

  def find_site
    @site = Site.find params[:site_id]
  end
end
