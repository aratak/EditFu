class EditorsController < ApplicationController
  layout 'editors'

  before_filter :authenticate_owner!

  def index
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

  def update
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
