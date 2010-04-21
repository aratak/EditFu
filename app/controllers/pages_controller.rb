require 'ftp_client'

class PagesController < ApplicationController
  before_filter :authenticate_user!, :only => [:show, :update]
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
    rescue FtpClientError
      flash.now[:error] = I18n.t(*connection_problem_message)
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
        rescue FtpClientError
          @message = connection_problem_message
        end
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
      if current_user.owner?
        message = I18n.t('page.update_error.owner', 
          :faq => MessageKeywords.faq, :support => MessageKeywords.support)
      else
        message = I18n.t('page.update_error.editor', 
          :owner => MessageKeywords.email(current_user.owner))
      end
      render_message message
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

  def find_site
    @site = current_user.find_site(params[:site_id])
  end

  def find_page
    @page = current_user.find_page(params[:site_id], params[:id])
    @site = @page.site
    @page
  end
end
