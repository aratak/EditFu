module PreferencesHelper

  def set_elements_max_height container="div.plan-wrapper", children="div.plan-label"
    return javascript_tag("setElementsHeight('#{container}', '#{children}')")
  end

end
