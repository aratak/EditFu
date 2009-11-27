class PagesController < ApplicationController
  before_filter :find_site

  def show
    @page = @site.pages.find params[:id]

    begin
      @sections = @page.sections
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
    redirect_to :action => :show
  end

  private

  def find_site
    @site = Site.find params[:site_id]
  end
end
