module PageHelper
  def page_attributes(page)
    page == @page ? { :id => 'current_page' } : {}
  end

  def new_page_content(&block)
    if current_user.trial_period_expired?
      render :partial => 'shared/trial_period_expired'
    elsif current_user.can_add_page? 
      capture(&block)
    else
     render :partial => 'shared/upgrade'
    end
  end
end
