class Owner < User
  has_many :sites, :dependent => :destroy
  has_many :editors, :dependent => :destroy

  def site_pages(site)
    site.pages
  end

  def add_editor(email)
    name = email[0, email.index('@')]
    editor = Editor.new :name => name, :email => email
    editor.owner = self
    editor.save
    editor
  end

  def find_site(site_id)
    sites.find site_id
  end

  def find_page(site_id, page_id)
    find_site(site_id).pages.find page_id
  end

  def send_confirmation_instructions
    Mailer.deliver_owner_confirmation_instructions(self)
  end
end
