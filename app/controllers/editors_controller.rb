class EditorsController < ApplicationController
  before_filter :authenticate_owner!
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
    find_editor
  end

  def edit
    find_editor
  end

  def update
    find_editor

    @editor.user_name = params[:editor][:user_name]
    @editor.email = params[:editor][:email]

    render_errors(:editor => @editor) unless @editor.save
  end

  def update_permissions
    find_editor.set_page_ids(params[:pages] || [])
  end

  def destroy
    find_editor.destroy
    redirect_to editors_path
  end

  private

  def find_editor
    @editor = current_user.editors.find params[:id]
  end
end
