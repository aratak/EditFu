class Admin::AuditsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :find_owner, :only => [:update, :destroy, :show]
  before_filter :find_all, :only => [:index, :show, :update]
  
  layout 'member'

  def index
  end

  def show
    # @subscriptions = @owner.subscriptions
    @owner.subscriptions.build
  end

  def update
    @owner.attributes = params[:owner]
    if @owner.save
      redirect_to :action => :show
    else
      render :action => :show
    end
  end


  private

  def find_owner
    @owner = Owner.find(params[:id])
  end
  
  def find_all
    @owners = Owner.all(:order => 'user_name')
  end


end
