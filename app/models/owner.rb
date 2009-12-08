class Owner < User
  has_many :sites, :dependent => :destroy
  has_many :editors, :dependent => :destroy

  def add_editor(email)
    name = email[0, email.index('@')]
    editor = Editor.new :name => name, :email => email
    editor.owner = self
    editor.save
    editor
  end

  def send_confirmation_instructions
    Mailer.deliver_owner_confirmation_instructions(self)
  end
end
