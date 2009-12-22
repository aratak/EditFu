class PlansController < ApplicationController
  before_filter :authenticate_owner!

  def update
    current_user.attributes = params[:owner]
    if current_user.plan == "free"
      [:pages, :sites].each do |assoc|
        ids = params[assoc] ? params[assoc].map(&:to_i) : []
        members = current_user.send(assoc)
        members.each do |member|
          member.destroy unless ids.include?(member.id)
        end
      end
    end

    if current_user.save
      redirect_to preferences_url
    else
      render :action => current_user.plan.to_sym
    end
  end

  # GET /preferences/plan/free
  def free
  end

  # GET /preferences/plan/professional
  def professional
  end
end
