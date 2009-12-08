class Editor < User
  belongs_to :owner

  def sites
    owner.sites
  end

  def send_confirmation_instructions
    Mailer.deliver_editor_confirmation_instructions(self)
  end
end
