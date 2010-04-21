module MessageKeywords
  def self.faq
    link_to 'FAQ', 'http://www.takeastep.me/editfu-faq/basics/'
  end

  def self.support
    link_to 'support', 'http://www.takeastep.me/editfu-contact-us/'
  end

  def self.email(user)
    user.user_name + ' ( ' + link_to(user.email, 'mailto:' + user.email) + ' )'
  end
  
  private

  def self.link_to(text, href)
    "<a href='#{href}' target='_blank'>#{text}</a>"
  end
end
