class EditorsController < ApplicationController
  layout 'editors'
  before_filter :authenticate_owner!

  def index
  end

  def new
    @editor = Editor.new
  end

  def create
    @editor = current_user.add_editor params[:editor][:email]
    if @editor.errors.empty?
      redirect_to editors_path
    else
      render :action => :new
    end
  end

  def show
    find_editor
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
