set :deploy_to, "/var/www/rails/#{application}/dev"
# set :branch, "stable"

set :branch do
  default_branch = "stable"

  branch = Capistrano::CLI.ui.ask "Branch to deploy (make sure to push the tag first): [#{default_branch}] "
  branch = default_branch if branch.empty?
  branch
end

set :rails_env, "dev"

