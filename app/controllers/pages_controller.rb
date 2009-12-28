require 'ftp_client'

class PagesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!, :only => [:show, :update_sections]
  before_filter :authenticate_owner!, :except => [:show, :update_sections]
  before_filter :check_trial_period, :only => [:create, :update_sections]
  before_filter :check_limits, :only => :create

  def show
    begin
      @sections = find_page.sections
      @error = "Page hasn't editable content" if @sections.blank?
      @page.save
    rescue FtpClientError => e
      @error = e.message
    end
  end

  def new
    find_site
    @page = Page.new 
  end

  def create
    @page = Page.new params[:page]
    @page.site = find_site

    if @page.save
      redirect_to site_page_path(@site, @page)
    else
      render :action => :new
    end
  end

  def destroy
    find_page.destroy
    redirect_to site_path(@site)
  end

  def update_sections
    find_page.sections = params[:sections]
    @page.save

    render :json => { :status => "ok" }
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
