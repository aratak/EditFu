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
      redirect_to site_path(@site)
    else
      render :action => :new
    end
  end

  def destroy
    @site = Site.find params[:id]
    @site.destroy
    redirect_to sites_path
  end
end
