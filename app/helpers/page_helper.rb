module PageHelper
  def site_attributes(site)
    { :id => 'current_site' } if site == @site
  end

  def page_attributes(page)
    { :id => 'current_page' } if page == @page
  end
end
