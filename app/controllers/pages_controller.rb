class PagesController < ApplicationController
  def show
    @page = Page.find params[:id]
    @site = @page.site
    render
    @page.save
  end

  def update_sections
    @page = Page.find params[:id]
    @site = @page.site
    
    @page.sections = params[:sections]
    @page.save
    redirect_to :action => :show
  end
end
