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

  def message_kind
    ([:info, :success, :warning, :error] & flash.keys).first
  end

  def popup(opts, &block)
    locals = { :id => nil, :clazz => nil }.merge(opts)
    render :layout => 'shared/popup', :locals => locals, &block
  end

  def popup_input(label, input)
    content_tag(:div, :class => 'input') do
      content_tag(:div, :class => 'box') do
        content_tag(:span, label, :class => 'label') + input
      end
    end
  end

  def show_message(page, key)
    message = I18n.t(key)
    page << "showMessage('success', '#{message}');"
  end
end
