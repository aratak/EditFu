class PlansController < ApplicationController
  before_filter :authenticate_owner!

  # GET /preferences/plan/edit
  def edit
  end

  # PUT /preferences/plan
  def update
    if current_user.update_attributes(params[:owner])
      redirect_to preferences_url
    else
      render :action => :edit
    end
  end
end
