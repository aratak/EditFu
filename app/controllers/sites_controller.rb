class SitesController < ApplicationController
  def index
  end

  def show
    @site = Site.find params[:id]
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new params[:site]
    if @site.save
      @site.init
      redirect_to site_path(@site)
    else
      render :action => :new
    end
  end
end
