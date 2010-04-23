class IdentitiesController < ApplicationController
  before_filter :authenticate_owner!

  def update
    current_user.identity = params[:owner][:identity]
    current_user.save
  end
end
