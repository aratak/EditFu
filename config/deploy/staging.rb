set :deploy_to, "/var/www/rails/#{application}/staging"

# set :branch, "staging"
set :branch do
  default_tag = `git tag`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end

set :rails_env, "staging"