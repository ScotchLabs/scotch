set :user, 'deploy'
set :domain, 'snstheatre.org'
set :application, "scotch"
 
set :repository, "git@github.com:Scotch-n-Soda/scotch.git"  # Your clone URL
set :scm, "git"
set :branch, "master"
set :scm_verbose, true
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{user}/#{application}"
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
end
