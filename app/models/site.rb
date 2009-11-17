class Site < ActiveRecord::Base
  has_many :pages

  def dirname
    File.join 'tmp/sites', name
  end
end
