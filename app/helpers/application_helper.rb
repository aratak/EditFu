# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def owner?
    yield if user_signed_in? && current_user.owner?
  end
  
  def admin?
    yield if user_signed_in? && current_user.admin?
  end
  
  def editor?
    yield if user_signed_in? && current_user.editor?
  end
  
  def pref_path
    if current_user.owner?
      ssl_owner_preferences_url
    else
      ssl_simple_preferences_url
    end
  end

  def help_link_for key
    add_stylesheet 'faq_link'
    faq_link = FAQS.key?(key.to_sym) ? FAQS[key.to_sym] : FAQS[:default]
    link_to "", faq_link, :class => "help_link link_#{key}", :target => "_blank"
  end


  def image_path(name)
    File.join(@type_dir, name)
  end

  def image_url(name)
    File.join(@site.http_url, image_path(name))
  end

  def menu_item(record, opts)
    name = record.class.name.downcase
    selected = record == opts[:selected]
    render :partial => 'layouts/menu_item', :locals => opts.merge({
      :id => "#{name}-#{record.id}-menu",
      :css_class => ('selected' if selected),
      :name => name, :selected => selected
    })
  end

  def selected_class(selected, classes = '')
    classes << ' selected' if selected
    classes.blank? ? {} : { :class => classes.strip } 
  end

  def message_kind
    ([:error, :failure, :warning, :info, :success] & flash.keys).first
  end

  def link_to_remove(path, text = 'Remove', question = '')
    link_to_function text, "showConfirmPopup('#{path}', '#{question}')", 
      :class => 'action important'
  end

  def show_popup(page, *opts)
    page.replace_html 'popup', *opts
    page << 'showPopup();'
  end

  def hide_popup(page, *targs)
    page << 'hidePopup();'
  end

  def hide_popup_with_errors(page, *targs)
    page << 'hidePopup();'
    show_error(page, *targs)
  end

  def show_success(page, *targs)
    message = I18n.t(*targs)
    show_message(page, 'success', message)
  end

  def show_error(page, *targs)
    message = I18n.t(*targs)
    show_message(page, 'error', message)
  end

  def show_message(page, kind, message)
    page << "showMessage('#{kind}', \"#{message}\");"
  end

  def show_error_messages(page, models)
    page << 'clearInputMessages();'
    models.each do |name, record|
      visited_attrs = []
      record.errors.each do |attr, message|
        unless visited_attrs.include?(attr)
          visited_attrs << attr
          message = message.first if message.kind_of?(Array)

          if attr.to_s == 'base'
            page << "showMessage('error', \"#{message}\");"
          else
            field = name.to_s + '_' + attr
            page << "showInputMessage('#{field}', \"#{message}\");"
          end
        end
      end
    end
  end

  def sort_sites(sites)
    sort sites, :name
  end

  def sort_pages(pages)
    sort pages, :path
  end

  def sort_users(users)
    sort users, :user_name
  end

  def sort(list, column)
    list.sort do |a, b|
      String.natcmp(a[column], b[column])
    end
  end

  def help_path
    if current_user.editor?
      'http://www.editfuapp.com/'
    elsif current_user.owner?
      'http://www.editfuapp.com/'
    end
  end
  
  def xhr_flash(page)
    page.replace_html 'messages', ''
    flash.each do |key, msg|
      page.insert_html :bottom, 'messages', :partial => 'layouts/flash/one', :locals => { :key => key, :msg => msg }
    end
    flash.clear
  end
  
  def analitycs
    render 'layouts/analitycs/analitycs'
  end
  
  private

  def classes(*args)
    { :class => args.compact.join(' ') }
  end
end
