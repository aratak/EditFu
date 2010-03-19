class EditorSettingsController < ApplicationController
  before_filter :authenticate_owner!

  def show
    find_editor
  end

  def update
    find_editor

    @editor.user_name = params[:editor][:user_name]
    @editor.email = params[:editor][:email]

    render_errors(:editor => @editor) unless @editor.save
  end

  private

  def find_editor
    @editor = current_user.editors.find params[:editor_id]
  end
end
