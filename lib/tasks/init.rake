# rake db:drop && rake db:create && rake db:migrate && rake db:seed && rake sync:pages

namespace :init do

  desc "Firstly create db"
  task :create => [ "db:create", "db:migrate" ]

  desc "recreate db and fill initial data"
  task :recreate => [ "db:drop", "init:create" ]

end