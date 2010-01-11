class Admin::AuditsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @audits = Audit.all(:include => :auditable, :order => 'created_at DESC')
    @audits = @audits.select { |audit| audit.auditable }
  end
end
