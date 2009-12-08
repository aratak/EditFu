class EditorConfirmationsController < ApplicationController
  before_filter :find_editor

  def edit
  end

  def update
    @editor.require_password
    [:name, :password, :password_confirmation].each do |attribute|
      @editor.update_attribute attribute, params[:editor][attribute]
    end

    if @editor.valid?
      @editor.confirm!
      sign_in_and_redirect @editor
    else
      render :edit
    end
  end

  private

  def find_editor
    @editor = Editor.find_by_confirmation_token params[:confirmation_token]
    unless @editor 
      flash[:notice] = 'Invalid confirmation token.'
      redirect_to root_path
    end
  end
end
