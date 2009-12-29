class FreePlansController < ApplicationController
  before_filter :authenticate_owner!
  
  def show
  end
  
  def update
    current_user.set_free_plan(Site.find(params[:sites]), Page.find(params[:pages]))
    redirect_to preferences_path
  end
end
