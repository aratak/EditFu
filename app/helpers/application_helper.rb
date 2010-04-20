# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def owner?
    yield if user_signed_in? && current_user.owner?
  end
  
  def admin?
    yield if user_signed_in? && current_user.admin?
  end
  
  def pref_path
    if current_user.owner?
      owner_preferences_path
    else
      simple_preferences_path
    end
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
    ([:info, :success, :warning, :error, :failure] & flash.keys).first
  end

  def link_to_remove(path, text = 'Remove')
    link_to_function text, "showConfirmPopup('#{path}')", :class => 'action important'
  end

  def show_popup(page, *opts)
    page.replace_html 'popup', *opts
    page << 'showPopup();'
  end

  def hide_popup(page, *targs)
    page << 'hidePopup();'
    show_success(page, *targs)
  end

  def show_success(page, *targs)
    message = I18n.t(*targs)
    show_message(page, 'success', message)
  end

  def show_message(page, kind, message)
    page << "showMessage('#{kind}', '#{message}');"
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
      'http://www.takeastep.me/editfu-faq/editing/'
    elsif current_user.owner?
      'http://www.takeastep.me/editfu-faq/'
    end
  end

  private

  def classes(*args)
    { :class => args.compact.join(' ') }
  end
end
