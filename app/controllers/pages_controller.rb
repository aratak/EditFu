class PagesController < ApplicationController
  layout 'sites'
  before_filter :find_site
  before_filter :authenticate_user!

  def show
    @page = @site.pages.find params[:id]

    begin
      @sections = @page.sections
      @error = "Page hasn't editable content" if @sections.blank?
      @page.save
    rescue FtpClientError => e
      @error = e.message
    end
  end

  def new
    @page = @site.pages.new 
  end

  def create
    @page = @site.pages.new params[:page]
    if @page.save
      redirect_to site_page_path(@site, @page)
    else
      render :action => :new
    end
  end

  def destroy
    @page = @site.pages.find params[:id]
    @page.destroy
    redirect_to site_path(@site)
  end

  def update_sections
    @page = @site.pages.find params[:id]
    @page.sections = params[:sections]
    @page.save

    render :json => { :status => "ok" }
  end

  private

  def find_site
    @site = Site.find params[:site_id]
  end
end
