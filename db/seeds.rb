# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# The current database dump consists of only Rocky and users who have logged
# in more than once since the launch of the site.  It has all images removed
# from users and groups and all email addresses have .blackhole.snstheatre.org
# appended so that there aren't any email from development environment
# mistakes.  All developers are encouraged to `rake db:reset' to use this new
# data.  In the future, perhaps some of these sanitation actions should occur
# on load time.

SerializationHelper::Base.new(YamlDb::Helper).load "db/data.yml.gz"

User.all.each do |u|
  u.password = "123456"
  u.smc = "123456"
  u.residence = "123 Main St"
  u.phone = "5555555555"
  u.save
end

p =Permission.create(:name => "uploadDocument", 
                     :description => "User can upload a document")

r = Role.find_by_name("Tech Head")
r.permissions << p
r.save

r = Role.find_by_name("Production Staff")
r.permissions << p
r.save
