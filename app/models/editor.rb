class Editor < User
  belongs_to :owner
  has_and_belongs_to_many :pages

  def subdomain
    owner.subdomain
  end

  def sites
    pages.map { |p| p.site }.uniq
  end

  def site_pages(site)
    site.pages & pages
  end

  def set_page_ids(ids)
    int_ids = ids.map { |id| id.to_i }
    owner_pages = owner.sites.map { |s| s.page_ids }.flatten
    self.page_ids = int_ids & owner_pages
  end

  def find_site(site_id)
    site = Site.find(site_id)
    return site if sites.include?(site)
  end

  def find_page(site_id, page_id)
    site = Site.find(site_id)
    page = Page.enabled.find(page_id)
    return page if page_ids.include?(page.id) && page.site == site
  end

  def send_confirmation_instructions
    Mailer.deliver_editor_invitation(self)
  end

  def trial_period_expired?
    owner.trial_period_expired?
  end  

  def enabled?
    owner.enabled?
  end

  def hold?
    owner.hold?
  end

  protected

  def before_update
    Mailer.deliver_editor_email_changes(self) if email_changed?
  end
end
