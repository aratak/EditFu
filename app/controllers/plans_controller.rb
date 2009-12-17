class PlansController < ApplicationController
  before_filter :authenticate_owner!

  # GET /preferences/plan/edit
  def edit
  end

  # PUT /preferences/plan
  def update
    if current_user.update_attributes(params[:owner])

      # TODO: need refactoring
      current_user.reload

      if current_user.plan == "free"
        current_user.sites.all(:conditions => ["sites.id NOT IN (?)", params[:sites]]).each { |site| site.destroy }
        current_user.pages.all(:conditions =>["pages.id NOT IN (?)", params[:pages]]).each { |page| page.destroy }
      end

      redirect_to preferences_url
    else
      render :action => :edit
    end
  end

  # GET /preferences/plan/free
  def free
  end

  # GET /preferences/plan/professional
  def professional
  end
end
