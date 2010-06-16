class Owner

  def site_pages(site)
    site.pages
  end

  def add_editor(email)
    editor_name = email.to_s.gsub(/@.*/, "")
    editor = Editor.new :user_name => editor_name, :email => email
    editor.owner = self
    editor.save
    editor
  end

  def find_site(site_id)
    sites.find_by_id site_id
  end

  def find_page(site_id, page_id)
    pages.find :first, :conditions => { :id => page_id, :site_id => site_id }
  end
  
end