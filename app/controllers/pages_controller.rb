class PagesController < ApplicationController
  def show
    @site = Site.find params[:site_id]
    @page = @site.pages.find params[:id]
    render
    @page.save
  end

  def update_sections
    @site = Site.find params[:site_id]
    @page = @site.pages.find params[:id]
    
    @page.sections = params[:sections]
    @page.save
    redirect_to :action => :show
  end
end
