class SitesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!

  def index
  end

  def show
    find_site
  end

  def new
    @site = current_user.sites.build
  end

  def create
    @site = current_user.sites.build params[:site]
    if @site.save
      redirect_to site_path(@site)
    else
      render :action => :new
    end
  end

  def edit
    find_site
  end

  def update
    find_site.update_attributes params[:site]
    if @site.save
      redirect_to site_path(@site)
    else
      render :action => :edit
    end
  end

  def destroy
    find_site.destroy
    redirect_to sites_path
  end

  private

  def find_site
    @site = current_user.sites.find params[:id]
  end
end
