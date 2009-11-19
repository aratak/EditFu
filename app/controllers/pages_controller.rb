class PagesController < ApplicationController
  def show
    @page = Page.find params[:id]
    @site = @page.site
  end
end
