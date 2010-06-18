require 'ftp_client'

class PagesController < ApplicationController
  before_filter :authenticate_all!, :only => [:show, :update]
  before_filter :authenticate_owner!, :except => [:show, :update]
  before_filter :find_site, :only => [:new, :create, :enable]
  before_filter :find_page, :only => [:show, :destroy, :update]

  def show
    begin
      FtpClient.get_page(@page)
      @sections = @page.sections
      @images = @page.images

      if @sections.blank? && @images.blank?
        flash.now[:warning] = I18n.t('page.no_content', :faq => MessageKeywords.faq)
      end
      @page.save
    rescue FtpClientError => e
      flash.now[:error] = I18n.t(*ftp_message(e))
    end
  end

  def new
  end

  def create
    @pages = []
    @has_errors = false
    @message = []

    params[:path].each do |path|
      page = @site.pages.create(:path => path)
      if page.errors.empty?
        begin
          FtpClient.get_page(page)
          flash[:success] = I18n.t('page.suspicious') if page.has_suspicious_sections?
          @pages << page
        rescue FtpClientError => e
          @has_errors = true
          flash[:error] = ftp_message(e)
        end
      else
        @has_errors = true
        @page_with_error = page
      end
    end
    

    if @message.empty?
      if @has_errors
        flash[:error] = I18n.t 'page.already_exist', { :site => @site.name, :page => @page_with_error.path}
      else 
        if @pages.size > 1 
          flash[:success] = I18n.t 'page.multicreated', { :site => @site.name }
        else
          flash[:success] = I18n.t 'page.created', { :site => @site.name, :page => @pages.first.path }
        end
      end
    end
    
  end

  def destroy
    @page.destroy
    flash[:success] = I18n.t('page.destroyed')
    redirect_to site_path(@site)
  end

  def update
    @page.sections = params[:sections]
    @page.images = params[:images]
    @page.save
    begin
      FtpClient.put_page(@page)
    rescue FtpClientError => e
      render_message ftp_update_message
      Mailer.deliver_content_update_error(current_user, e.message) if current_user.editor?
    end
  end

  def enable
    @site.pages.each do |page|
      page.enabled = params[:page] && params[:page][page.id.to_s]
      page.save!
    end
    flash[:success] = I18n.t('page.enabled')
  end

  private

  def ftp_message(e)
    if e.code == '550'
      ftp_not_found_message
    else
      connection_problem_message
    end
  end

  def connection_problem_message
    if current_user.owner?
      ['site.connection_problem.owner']
    else
      ['site.connection_problem.editor', {:owner => MessageKeywords.email(current_user.owner)}]
    end
  end

  def ftp_not_found_message
    if current_user.owner?
      ['page.not_found.owner']
    else
      ['page.not_found.editor', 
        {:owner => MessageKeywords.email(current_user.owner)}]
    end
  end

  def ftp_update_message
    if current_user.owner?
      I18n.t('page.update_error.owner', 
        :faq => MessageKeywords.faq, :support => MessageKeywords.support)
    else
      I18n.t('page.update_error.editor', :owner => MessageKeywords.email(current_user.owner))
    end
  end

  def find_site
    @site = current_user.find_site(params[:site_id])
  end

  def find_page
    @page = current_user.find_page(params[:site_id], params[:id])
    @site = @page.site if @page
      
    erase_uri_and_redirect(sites_path) and return(false) unless @page
    return @page
  end
end
