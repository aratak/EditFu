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
    locals = { :id => nil, :clazz => nil, :hint => nil, :action => []}.merge(opts)
    render :layout => 'shared/popup', :locals => locals, &block
  end

  def popup_input(opts = {}, &block)
    locals = { :clazz => nil, :hint => nil, :has_hint => nil }.merge(opts)
    locals[:has_hint] = 'has-hint' if opts.has_key?(:hint)
    render :layout => 'shared/popup_input', :locals => locals, &block
  end

  def label_input(label, opts = {}, &block)
    popup_input(opts) do
      content_tag(:div, label, :class => 'label') + capture(&block)
    end
  end

  def show_message(page, key)
    message = I18n.t(key)
    page << "showMessage('success', '#{message}');"
  end

  private

  def classes(*args)
    { :class => args.compact.join(' ') }
  end
end
