class PagesController < ApplicationController
  layout 'sites'
  before_filter :find_site
  before_filter :authenticate_user!

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
    @site = current_user.sites.find params[:site_id]
  end

  def find_page
    @page = @site.pages.find params[:id]
  end
end
