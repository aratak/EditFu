class Admin::OwnersController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :find_owner, :only => [:update, :destroy, :show]
  layout 'member'

  def index
    @owner = Owner.all(:order => 'user_name').first
    if @owner
      redirect_to admin_owner_path(@owner)
    end
  end

  def show
    @owners = Owner.all(:order => 'user_name')
  end

  def destroy
    @owner.destroy

    flash[:success] = I18n.t('admin.owner.canceled', :email => @owner.email)
    redirect_to admin_owners_path
  end

  def update
    @owner.enabled = params[:owner][:enabled]
    @owner.hold = params[:owner][:hold]
    @owner.send(:update_without_callbacks)

    flash[:success] = I18n.t('admin.owner.updated')
    redirect_to admin_owner_path(@owner)
  end

  private

  def find_owner
    @owner = Owner.find(params[:id])
  end
end
