class EditorsController < ApplicationController
  before_filter :authenticate_owner!
  before_filter :redirect_from_cookie, :only => [:index]
  before_filter :find_editor, :only => [:show, :edit, :update, :update_permissions, :destroy]

  def index
    @editors = current_user.editors
  end

  def new
    @editor = Editor.new
  end

  def create
    @editor = current_user.editors.create params[:editor]
    
    if @editor.errors.empty?
      flash[:notice] = I18n.t('editor.created', :name => @editor.email)
    else
      flash[:notice] = @editor.errors.full_messages.uniq.first # I18n.t('editor.wrong')
      render :action => :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @editor.user_name = params[:editor][:user_name]
    @editor.email = params[:editor][:email]

    if @editor.save
      flash[:notice] = I18n.t('editor.updated')
    else
      flash[:error] = I18n.t('editor.wrong')
      render :action => :edit
    end
    
  end

  def update_permissions
    @editor.set_page_ids(params[:pages] || [])
    flash[:success] = I18n.t('editor.permissions_updated')
  end

  def destroy
    @editor.destroy
    flash[:success] = I18n.t("editor.destroyed")
    redirect_to(editors_path)
  end

  private

  def find_editor
    @editor = current_user.editors.find_by_id(params[:id])
    erase_uri_and_redirect(editors_path) and return false unless @editor
    @editor
  end
end
