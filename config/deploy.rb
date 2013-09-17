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
    solr.reindex if 'y' == Capistrano::CLI.ui.ask("\n\n Should I reindex all models? (anything but y will cancel)")
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Make symlink for database yaml" 
  task :symlink_config do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    run "rm #{release_path}/config/sunspot.yml"
    run "ln -nfs #{shared_path}/config/sunspot.yml #{release_path}/config/sunspot.yml"
    run "ln -fs #{shared_path}/upload #{release_path}/public/upload"
  end

  desc 'create shared data and pid dirs for Solr'
  task :setup_solr_shared_dirs do
    conf dir is not shared as different versions need different configs
    %w(data pids).each do |path|
      run "mkdir -p #{shared_path}/solr/#{path}"    
    end
  end


  desc 'substituses current_path/solr/data and pids with symlinks to the shared dirs'
  task :link_to_solr_shared_dirs do
    %w(solr/data solr/pids).each do |solr_path|
      run "rm -fr #{current_path}/#{solr_path}" #removing might not be necessary with proper .gitignore setup
      run "ln -s #{shared_path}/#{solr_path} #{current_path}/#{solr_path}"
    end
  end
end

namespace :solr do
  desc "start solr"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:start"
  end
  desc "stop solr"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:stop"
  end

  desc "stop solr, remove data, start solr, reindex all records"
  task :hard_reindex, :roles => :app do
    stop
    run "rm -rf #{shared_path}/solr/data/*"
    start
    reindex
  end


  desc "simple reindex" #note the yes | reindex to avoid the nil.chomp error
  task :reindex, roles: :app do
    run "cd #{current_path} && yes | RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex"
  end
end

after "deploy:create_symlink", "deploy:symlink_config"
after 'deploy:setup', 'deploy:setup_solr_shared_dirs'
after 'deploy:update', 'deploy:link_to_solr_shared_dirs'
