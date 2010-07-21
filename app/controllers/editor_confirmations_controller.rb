class EditorConfirmationsController < ApplicationController
  before_filter :find_editor
  before_filter :load_logo
  layout 'public'

  def edit
  end

  def update
    @editor.require_password
    [:user_name, :password, :password_confirmation].each do |attribute|
      @editor.update_attribute attribute, params[:editor][attribute]
    end

    if @editor.valid?
      @editor.confirm!
      sign_in_and_redirect :user, @editor
    else
      render :edit
    end
  end

  private

  def find_editor
    @editor = Editor.find_by_confirmation_token params[:confirmation_token]
    unless @editor 
      flash[:failure] = 'Invalid confirmation token.'
      redirect_to new_user_session_path
    end
  end
  
  def load_logo
    @company_owner = @editor.owner
    @company_logo = @company_owner.identity if @company_owner
  end
  
  
end
