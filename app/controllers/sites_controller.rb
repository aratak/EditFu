class SitesController < ApplicationController
  def show
    @sites = Site.all
    @site = Site.find params[:id]
    @page = nil
  end
end
