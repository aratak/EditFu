module SitesHelper
  def site_attributes(site)
    site == @site ? { :id => 'current_site' } : {}
  end

  def new_site_content(&block)
    if current_user.trial_period_expired?
      render :partial => 'shared/trial_period_expired'
    elsif current_user.can_add_site?
      capture(&block)
    else
      render :partial => 'shared/upgrade'
    end
  end

  def render_site_root(site)
    ul = ''
    site.root_folders.reverse.each do |name|
      span = content_tag :span, name
      li = content_tag :li, span + ul, :class => :folder
      ul = content_tag :ul, li
    end
    ul
  end
end
