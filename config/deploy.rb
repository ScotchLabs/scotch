require 'bundler/capistrano'
require 'sidekiq/capistrano'

set :stages, %w{staging production}
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :user, 'deploy'
set :domain, 'snstheatre.org'
set :application, "scotch"
 
set :repository, "git@github.com:Scotch-n-Soda/scotch.git"  # Your clone URL
set :scm, "git"
set :scm_verbose, true
set :deploy_via, :remote_cache
set :use_sudo, false
 
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
 
role :web, domain						 # Your HTTP server, Apache/etc
role :app, domain						  # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
 
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Make symlink for database yaml" 
  task :symlink_config do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    run "rm #{release_path}/config/sunspot.yml"
    run "ln -nfs #{shared_path}/config/sunspot.yml #{release_path}/config/sunspot.yml"
    run "ln -fs #{shared_path}/upload #{release_path}/public/upload"
  end
end

after "deploy:create_symlink", "deploy:symlink_config"
