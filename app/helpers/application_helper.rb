# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def owner?
    yield if user_signed_in? && current_user.kind_of?(Owner)
  end

  def image_path(name)
    File.join(@type_dir, name)
  end

  def image_url(name)
    File.join(@site.site_url, image_path(name))
  end

  def selected_class(selected, classes = '')
    classes << ' selected' if selected
    classes.blank? ? {} : { :class => classes.strip } 
  end
end
