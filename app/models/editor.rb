class Editor < User
  belongs_to :owner
  has_and_belongs_to_many :pages

  def identity
    owner.identity
  end

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
    site = Site.find_by_id(site_id)
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
  
  def credit_card_expired?
    owner.credit_card_expired?
  end

  protected

  def before_update
    Mailer.deliver_editor_email_changes(self) if email_changed?
  end
end





# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  email                :string(100)     not null
#  encrypted_password   :string(40)
#  password_salt        :string(20)
#  confirmation_token   :string(20)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(20)
#  remember_token       :string(20)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  domain_name          :string(255)
#  owner_id             :integer(4)
#  type                 :string(10)      not null
#  enabled              :boolean(1)      default(TRUE), not null
#  user_name            :string(255)
#  company_name         :string(255)
#  plan_id              :integer(4)      default(1)
#

