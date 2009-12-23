module EditorsHelper
  def new_editor_content(&block)
    if current_user.can_add_editor?
      capture(&block)
    else
      render :partial => 'shared/upgrade'    
    end
  end
end
