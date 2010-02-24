class SitesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :authenticate_owner!, :except => [:index, :show, :ls]
  before_filter :check_trial_period, :only => :create
  before_filter :check_limits, :only => :create

  def index
  end

  def show
    find_site
  end

  def new
    @site = Site.new
    render :action => 'new', :layout => 'sites2'
  end

  def create
    @site = Site.new params[:site]
    @site.owner = current_user

    validate_and_save
  end

  def edit
    find_site
    render :action => 'edit', :layout => 'sites2'
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
    if params[:site_id]
      site = current_user.sites.find params[:site_id]
    else
      site = Site.new params[:site]
      site.site_root = '/'
    end

    begin
      @files = FtpClient.ls(site, params[:folder]).select do |f| 
        f[:type] == :folder || /\.html?$/ =~ f[:name]
      end
      render :layout => false
    rescue FtpClientError => e
      head :ftp_error => e.message
    end
  end

  private

  def find_site
    @site = current_user.find_site(params[:id])
  end

  def validate_and_save
    if !@site.validate_and_save
      render :json => @site.errors
    end
  end

  def check_limits
    redirect_to :action => :new unless current_user.can_add_site?
  end
end
