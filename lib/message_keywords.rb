module MessageKeywords
  def self.faq
    link_to_blank 'FAQ', 'http://www.takeastep.me/editfu-faq/basics/'
  end

  def self.contact_us(text)
    link_to_blank text, 'http://www.takeastep.me/editfu-contact-us/'
  end

  def self.support
    contact_us('support')
  end

  def self.support_email
    email_link('support@editfu.com')
  end

  def self.editfu
    link_to 'www.editfu.com'
  end

  def self.email(user)
    user.user_name + ' ( ' + email_link(user.email) + ' )'
  end

  def self.company_domain(user)
    link_to user.company_domain
  end

  private

  def self.email_link(email)
    link_to_blank(email, 'mailto:' + email)
  end
  
  def self.link_to(domain)
    "<a href='http://#{domain}'>#{domain}</a>"
  end

  def self.link_to_blank(text, href)
    "<a href='#{href}' target='_blank'>#{text}</a>"
  end
end
