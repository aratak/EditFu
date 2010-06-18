class SitesController < ApplicationController
  before_filter :authenticate_all!, :only => [:index]
  before_filter :authenticate_owner!, :except => [:index, :ls]
  before_filter :find_site, :only => [:show, :edit, :update, :destroy]
  before_filter :redirect_from_cookie, :only => [:index]

  def index
  end

  def show
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new params[:site]
    @site.owner = current_user

    if @site.validate_and_save
      flash[:success] = I18n.t('site.created', :name => @site.name)
    else
      render :action => :new
    end
  end

  def edit
  end

  def update
    @site.attributes= params[:site]
    if @site.validate_and_save
      flash[:success] = I18n.t('site.updated')
    else
      render :action => :edit
    end
  end

  def destroy
    @site.destroy
    flash[:success] = I18n.t('site.destroyed')
    redirect_to sites_path
  end

  def ls
    @files = params[:files]

    if params[:site_id]
      site = current_user.sites.find params[:site_id]
    else
      site = Site.new params[:site]
      site.site_root = '/'
    end

    render_tree(site, params[:folder]) do
      FtpClient.ls(site, params[:folder])
    end
  end

  def tree
    site = current_user.sites.find params[:site_id]
    render_tree(site, site.site_root) do
      FtpClient.tree(site, site.site_root)
    end
  end

  private

  def find_site
    @site = current_user.find_site(params[:id])
    erase_uri_and_redirect(sites_path) and return(false) unless @site
    
    return @site
  end

  def validate_and_save
    render_errors(:site => @site) unless @site.validate_and_save
  end

  def render_tree(site, folder)
    begin
      files = FtpClient.tree(site, folder)
      render :partial => 'tree', :locals => { :files => yield }
    rescue FtpClientError => e
      head :ftp_error => e.message
    end
  end
end
