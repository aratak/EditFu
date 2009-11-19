module PageHelper
  def page_attributes(page)
    page == @page ? { :id => 'current_page' } : {}
  end
end
