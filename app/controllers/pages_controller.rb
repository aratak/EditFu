require 'ftp_client'

class PagesController < ApplicationController
  before_filter :authenticate_all!, :only => [:show, :update]
  before_filter :authenticate_owner!, :except => [:show, :update]

  def show
    begin
      FtpClient.get_page(find_page)
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
    find_site
  end

  def create
    find_site
    @pages = []

    params[:path].each do |path|
      page = @site.pages.create(:path => path)
      if page.errors.empty?
        @message = ['page.created', { :site => @site.name, :page => page.path}]
        begin
          FtpClient.get_page(page)
          @message = ['page.suspicious'] if page.has_suspicious_sections?
          @pages << page
        rescue FtpClientError => e
          @message = ftp_message(e)
        end
      else
        @message = ['page.already_exist', { :site => @site.name, :page => page.path}]
      end
    end
  end

  def destroy
    find_page.destroy
    flash[:success] = I18n.t('page.destroyed')
    redirect_to site_path(@site)
  end

  def update
    find_page.sections = params[:sections]
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
    find_site.pages.each do |page|
      page.enabled = params[:page] && params[:page][page.id.to_s]
      page.save!
    end
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
    @page
  end
end
