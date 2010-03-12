class Admin::OwnersController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @owners = Owner.all(:order => 'user_name')
  end

  def show
    find_owner
  end

  def destroy
    find_owner.destroy

    flash[:success] = I18n.t('admin.owner.canceled', :email => @owner.email)
    redirect_to admin_owners_path
  end

  def enable
    find_owner.enabled = true
    @owner.save!

    flash[:success] = I18n.t('admin.owner.enabled')
    redirect_to admin_owner_path(@owner)
  end

  def disable
    find_owner.enabled = false
    @owner.save!

    flash[:success] = I18n.t('admin.owner.disabled')
    redirect_to admin_owner_path(@owner)
  end

  private

  def find_owner
    @owner = Owner.find(params[:id])
  end
end
