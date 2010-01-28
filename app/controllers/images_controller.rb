class ImagesController < ApplicationController
  before_filter :authenticate_user!
  layout 'page'

  def new
    find_site

    begin
      dir = "#{@site.site_root}/#{Site::IMAGES_FOLDER}" 
      @images = FtpClient.ls(@site, dir).map { |f| f[:name] }.sort!
    rescue
      @images = []
    end
  end

  def create
    begin
      image = params[:image]
      image_src = FtpClient.put_image(find_site, image.path, image.original_filename)
      render :text => {:src => image_src}.to_json
    rescue Exception => e
      render :text => {:error => e.message}.to_json
    end
  end

  private

  def find_site
    @site = Site.find params[:site_id]
  end
end
