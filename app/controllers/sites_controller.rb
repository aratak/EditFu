class SitesController < ApplicationController
  layout 'sites'

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

  def edit
    @site = Site.find params[:id]
  end

  def update
    @site = Site.find params[:id]
    @site.update_attributes params[:site]
    if @site.save
      redirect_to site_path(@site)
    else
      render :action => :edit
    end
  end

  def destroy
    @site = Site.find params[:id]
    @site.destroy
    redirect_to sites_path
  end
end
