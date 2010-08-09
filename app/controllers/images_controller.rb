class ImagesController < ApplicationController
  before_filter :authenticate_all!
  before_filter :find_site, :only => [ :new, :create ]
  before_filter :type_dir, :only => [ :new, :create ] 

  def new
    @action = params[:imageAction]

    begin
      dir = File.join(@site.site_root, @type_dir)
      @images = FtpClient.ls(@site, dir).map { |f| f[:name] }
    rescue
      @images = []
    end
  end

  def create
    begin
      image = params[:image]
      remote_path = File.join(@type_dir, image.original_filename)
      name = FtpClient.put_image(@site, image.path, remote_path)
      render :partial => 'show', :content_type => 'text/plain', :locals => { :name => name }
    rescue Exception => e
      logger.warn 'Got exception in image upload: ' + e.message
      render :nothing => true
    end
  end

  private

  def type_dir
    @type = File.basename(image_type)
    @type_dir = File.join Site::IMAGES_FOLDER, @type
    @type_dir
  end

  def find_site
    @site = Site.find params[:site_id]
  end
  
  def image_type
    result = case params[:type].to_s.downcase
      when 'only'     then Site::SWAP_FOLDER
      when 'content'  then Site::MCE_FOLDER
      else params[:type]
    end
    result
  end
  
end
