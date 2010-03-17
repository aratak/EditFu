# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def owner?
    yield if user_signed_in? && current_user.owner?
  end
  
  def admin?
    yield if user_signed_in? && current_user.admin?
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
    ([:info, :success, :warning, :error, :failure] & flash.keys).first
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

  def show_popup(page, *opts)
    page.replace_html 'popup', *opts
    page << 'showPopup();'
  end

  def hide_popup(page, message_key)
    page << 'hidePopup();'
    show_message(page, message_key)
  end

  def show_message(page, key)
    message = I18n.t(key)
    page << "showMessage('success', '#{message}');"
  end

  def show_error_messages(page, models)
    page << 'clearInputMessages();'
    models.each do |name, record|
      record.errors.each do |attr, message|
        if(attr == :base)
          page << "showMessage('error', \"#{message}\");"
        else
          field = name.to_s + '_' + attr
          page << "showInputMessage('#{field}', \"#{message}\");"
        end
      end
    end
  end

  private

  def classes(*args)
    { :class => args.compact.join(' ') }
  end
end
