class EditorConfirmationsController < ApplicationController
  before_filter :find_editor

  def edit
  end

  def create
    @user.require_password
    [:name, :password, :password_confirmation].each do |attribute|
      @user.update_attribute attribute, params[:user][attribute]
    end

    if @user.valid?
      @user.confirm!
      sign_in_and_redirect @user
    else
      render :edit
    end
  end

  private

  def find_editor
    @user = User.find_by_confirmation_token params[:confirmation_token]
    if !@user || !@user.editor?
      flash[:notice] = 'Invalid confirmation token.'
      redirect_to root_path
    end
  end
end
