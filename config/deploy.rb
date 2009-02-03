default_run_options[:pty] = true
set :use_sudo, false
set :scm_verbose, true

set :user, "nastosj"
set :application, "tagalus"
set :repository,  "git@github.com:jnpdx/tagalus.git"

ssh_options[:forward_agent] = true

set :branch, "master"

set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "etc/rails_apps/tagalus"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, "git"


role :app, "johnnastos.com"
role :web, "johnnastos.com"
role :db,  "johnnastos.com", :primary => true