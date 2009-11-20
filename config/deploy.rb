set :application, 'edit-fu'
set :rails_env, "production"

set :use_sudo, false
set :user, 'deploy'

set :scm, :git
set :repository,  "dev.anahoret.com:/var/git/#{application}.git"
set :deploy_to, "/var/www/rails/#{application}"
set :deploy_via, :copy
set :copy_strategy, :export

set :deploy_host, '174.143.144.69'
role :app, "#{deploy_host}"
role :web, "#{deploy_host}"
role :db,  "#{deploy_host}", :primary => true

namespace :deploy do
  task :install_gems do
    run "cd #{current_path} && rake gems:install"
  end

  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

