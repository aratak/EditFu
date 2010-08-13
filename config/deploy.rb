set :stages, %w(staging dev production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, 'edit-fu'

set :use_sudo, false
set :user, 'deploy'

set :scm, :git
set :repository,  "dev.anahoret.com:/var/git/#{application}.git"
# moved to deploy/{environment}.rb
# set :deploy_to, "/var/www/rails/#{application}"
set :deploy_via, :copy
set :copy_strategy, :export

set :deploy_host, '174.143.144.69'
role :app, "#{deploy_host}"
role :web, "#{deploy_host}"
role :db,  "#{deploy_host}", :primary => true

after "deploy:symlink", "deploy:update_crontab"
after "deploy:symlink", "deploy:destroy_cache"

namespace :deploy do
  task :install_gems do
    run "cd #{current_path} && rake RAILS_ENV=#{rails_env} gems:install"
  end

  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :destroy_cache do
    run "rm -f #{current_path}/public/stylesheets/*-cached.* && rm -f #{current_path}/public/javascripts/*-cached.*"
  end

  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
  
end

