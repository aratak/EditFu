class Editor < User
  belongs_to :owner
  has_and_belongs_to_many :pages

  def sites
    pages.map { |p| p.site }.uniq
  end

  def send_confirmation_instructions
    Mailer.deliver_editor_confirmation_instructions(self)
  end
end
