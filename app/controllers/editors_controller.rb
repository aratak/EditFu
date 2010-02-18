class EditorsController < ApplicationController
  layout 'editors'

  before_filter :authenticate_owner!
  before_filter :check_trial_period, :only => :create
  before_filter :check_limits, :only => :create

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
    render 'show2', :layout => 'editors2' if params[:design]
  end

  def update
    find_editor.set_page_ids(params[:pages] || [])
    flash[:success] = 'Editor permissions was updated.'
    redirect_to @editor
  end

  def destroy
    find_editor.destroy
    redirect_to editors_path
  end

  private

  def find_editor
    @editor = current_user.editors.find params[:id]
  end

  def check_limits
    redirect_to :action => :new unless current_user.can_add_editor?
  end
end
