class Admin::OwnersController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @owners = Owner.all(:order => 'name')
  end

  def show
    @owner = Owner.find(params[:id])
  end

  def destroy
    @owner = Owner.find(params[:id])
    @owner.destroy

    flash[:success] = I18n.t('admin.owner.canceled', :email => @owner.email)
    redirect_to admin_owners_path
  end
end
