class Admin::AuditsController < ApplicationController
  def signup
    @owners = Owner.all :order => 'created_at DESC'
  end
end
