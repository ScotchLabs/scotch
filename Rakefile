# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'

Scotch::Application.load_tasks

desc "Update Mailgun Lists"
task :update_mailgun => :environment do |t|
  puts "Updating active Groups"
  Group.active.each do |g|
    puts "Updating #{g.name}"
    g.update_mailing_list

    puts "Updating #{g.name}'s lists"
    g.message_lists.each do |m|
      m.update_mailing_list
    end

    puts "Updating #{g.name}'s active Positions and Roles"
    g.positions.each do |p|
      p.add_recipients
    end
  end

end
