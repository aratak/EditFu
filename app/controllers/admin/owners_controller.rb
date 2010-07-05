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
    @owner.enabled = params[:owner][:enabled] unless params[:owner][:enabled].nil?
    @owner.hold = params[:owner][:hold] unless params[:owner][:hold].nil?
    @owner.send(:update_without_callbacks)

    flash[:success] = I18n.t('admin.owner.updated')
    
    respond_to do |format|
      format.html { redirect_to admin_owner_path(@owner) }
      format.js
    end
    
  end

  private

  def find_owner
    @owner = Owner.find(params[:id])
  end
end
