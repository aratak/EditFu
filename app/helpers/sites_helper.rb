module SitesHelper
  def site_attributes(site)
    site == @site ? { :id => 'current_site' } : {}
  end
end
