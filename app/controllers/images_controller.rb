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
      name = FtpClient.put_image(find_site, image.path, image.original_filename)
      render :partial => 'show', :locals => { :name => name }
    rescue Exception => e
      render :nothing => true
    end
  end

  private

  def find_site
    @site = Site.find params[:site_id]
  end
end
