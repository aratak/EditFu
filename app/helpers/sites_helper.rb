module SitesHelper
  def site_attributes(site)
    site == @site ? { :id => 'current_site' } : {}
  end

  def new_site_content(&block)
    if current_user.can_add_site?
      capture(&block)
    else
      render :partial => 'shared/upgrade'
    end
  end
end
