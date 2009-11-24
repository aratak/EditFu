class PagesController < ApplicationController
  def show
    @page = Page.find params[:id]
    @site = @page.site
  end

  def update_sections
    @page = Page.find params[:id]
    @site = @page.site
    
    @page.sections = params[:sections]
    redirect_to :action => :show
  end
end
