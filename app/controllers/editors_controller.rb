class EditorsController < ApplicationController
  before_filter :authenticate_owner!
  before_filter :redirect_from_cookie, :only => [:index]
  before_filter :find_editor, :only => [:show, :edit, :update, :update_permissions, :destroy]
  layout nil

  def index
    unless current_user.editors.empty?
      redirect_to editor_path(current_user.editors.first)
    end
  end

  def new
    @editor = Editor.new
  end

  def create
    @editor = current_user.editors.create params[:editor]
    render_errors(:editor => @editor) unless @editor.errors.empty?
  end

  def show
  end

  def edit
  end

  def update
    @editor.user_name = params[:editor][:user_name]
    @editor.email = params[:editor][:email]

    render_errors(:editor => @editor) unless @editor.save
  end

  def update_permissions
    @editor.set_page_ids(params[:pages] || [])
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
