module AuditsHelper
  def action(audit)
    return 'created' if audit.action == 'create'
    "#{audit.old_attributes[:plan]} -> #{audit.new_attributes[:plan]}"
  end
end
