class OwnersController < ApplicationController
  before_filter :authenticate_owner!, :only => :destroy

  def new
    @owner = Owner.new
  end

  def create
    @owner = Owner.new params[:owner]
    @owner.require_password
    if @owner.save
      flash[:success] = t('devise.confirmations.send_instructions')
      send_redirect root_path
    else
      render_errors :owner => @owner
    end
  end

  def destroy
    current_user.destroy

    flash[:success] = "Your acccount was canceled."
    redirect_to root_url
  end
  
  def terms_of_service
    render :update do |page|
      page['terms'].replace_html :partial => 'owners/terms_of_service'
      page['text_of_terms_of_service'].show(500)
    end
  end
end
