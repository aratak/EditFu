class Admin::OwnersController < ApplicationController
  before_filter :authenticate_admin!
  layout 'member'

  def index
    @owner = Owner.all(:order => 'user_name').first
    if @owner
      redirect_to admin_owner_path(@owner)
    end
  end

  def show
    @owners = Owner.all(:order => 'user_name')
    find_owner
  end

  def destroy
    find_owner.destroy

    flash[:success] = I18n.t('admin.owner.canceled', :email => @owner.email)
    redirect_to admin_owners_path
  end

  def enable
    find_owner.enabled = params[:enabled]
    @owner.save!

    flash[:success] = I18n.t('admin.owner.enabled')
    redirect_to admin_owner_path(@owner)
  end

  private

  def find_owner
    @owner = Owner.find(params[:id])
  end
end
