# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def owner?
    yield if user_signed_in? && current_user.kind_of?(Owner)
  end

  def image_path(name)
    Site::IMAGES_FOLDER + '/' + name
  end

  def image_url(name)
    @site.site_url + '/' + image_path(name)
  end
end
