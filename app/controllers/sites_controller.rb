class SitesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :authenticate_owner!, :except => [:index, :show, :ls]

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

    validate_and_save
  end

  def edit
    find_site
  end

  def update
    find_site.attributes= params[:site]
    validate_and_save
  end

  def destroy
    find_site.destroy
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
  end

  def validate_and_save
    unless @site.validate_and_save
      render :update do |page|
        show_error_messages(page, 'site', @site)
      end
    end
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
