module MessageKeywords
  def self.faq
    link_to 'FAQ', 'http://www.takeastep.me/editfu-faq/basics/'
  end

  def self.contact_us(text)
    link_to text, 'http://www.takeastep.me/editfu-contact-us/'
  end

  def self.support
    contact_us('support')
  end

  def self.support_email
    email_link('support@editfu.com')
  end

  def self.email(user)
    user.user_name + ' ( ' + email_link(user.email) + ' )'
  end
  
  private

  def self.email_link(email)
    link_to(email, 'mailto:' + email)
  end
  
  def self.link_to(text, href)
    "<a href='#{href}' target='_blank'>#{text}</a>"
  end
end
