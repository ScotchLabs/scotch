# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake/dsl_definition'
require 'rake'

class Rails::Application
      include Rake::DSL if defined?(Rake::DSL)
end

Scotch::Application.load_tasks
