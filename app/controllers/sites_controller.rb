class SitesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :authenticate_owner!, :except => [:index, :show]

  def index
  end

  def show
    find_site
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new params[:site]
    @site.owner = current_user

    if @site.valid? && @site.check_connection
      @site.save(false)
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
    @site = current_user.find_site(params[:id])
  end
end
