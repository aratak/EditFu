require 'ftp_client'

class PagesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!, :only => [:show, :update]
  before_filter :authenticate_owner!, :except => [:show, :update]
  before_filter :check_trial_period, :only => [:create, :update]
  before_filter :check_limits, :only => :create

  def show
    begin
      FtpClient.get_page(find_page)
      @sections = @page.sections
      @images = @page.images

      if @sections.blank? && @images.blank?
        flash.now[:warning] = "Page hasn't editable content" 
      end
      @page.save
    rescue FtpClientError => e
      flash.now[:error] = e.message
    end
  end

  def new
    find_site
    @page = Page.new 
  end

  def create
    @page = Page.new params[:page]
    @page.site = find_site

    unless @page.save
      render :json => @page.errors
    end
  end

  def destroy
    find_page.destroy
    redirect_to site_path(@site)
  end

  def update
    find_page.sections = params[:sections]
    @page.images = params[:images]
    @page.save
    FtpClient.put_page(@page)
  end

  private

  def find_site
    @site = current_user.find_site(params[:site_id])
  end

  def find_page
    @page = current_user.find_page(params[:site_id], params[:id])
    @site = @page.site
    @page
  end

  def check_limits
    redirect_to :action => :new unless current_user.can_add_page?
  end
end
