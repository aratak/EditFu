module ErrorsStuff
  def self.included m
    return unless m < ActionController::Base
    m.helper_method :render_404, :render_422, :render_500           
    
    m.rescue_from(ActiveRecord::RecordNotFound,
                ActionController::UnknownAction,  
                            :with => :render_404)
  end

  def render_404
    render_error(404)
  end

  def render_422
    render_error(422)
  end

  def render_500
    render_error(500)
  end

  def render_error(status_code)
    render :file => "#{RAILS_ROOT}/public/#{status_code}.html", :status => status_code
  end
end
