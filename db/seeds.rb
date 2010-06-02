# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User.transaction do

  User.create(:email => "achivett@andrew.cmu.edu", :first_name => "Anthony", :last_name => "Chivetta",
              :password => "123456", :confirmed_at => Time.now.zone)
  User.create(:email => "amgross@andrew.cmu.edu", :first_name => "Aaron", :last_name => "Gross",
              :password => "123456", :confirmed_at => Time.now.zone)
  User.create(:email => "dfreeman@andrew.cmu.edu", :first_name => "Daniel", :last_name => "Freeman",
              :password => "123456", :confirmed_at => Time.now.zone)
  User.create(:email => "jrfriedr@andrew.cmu.edu", :first_name => "Jasmine", :last_name => "Friedrich",
              :password => "123456", :confirmed_at => Time.now.zone)
  User.create(:email => "mdickoff@andrew.cmu.edu", :first_name => "Matt", :last_name => "Dickoff",
              :password => "123456", :confirmed_at => Time.now.zone)
  User.create(:email => "sewillia@andrew.cmu.edu", :first_name => "Spencer", :last_name => "Williams",
              :password => "123456", :confirmed_at => Time.now.zone)

  grp = Group.create(:type => "Group", :name => "SYSTEM GROUP", :description => "System group for site wide privilages")
  Role.create(:name => "Member", :group_type => "Group")
  adm = Role.create(:name => "Administrator", :group_type => "Group")
  su = RolePermission.create(:name => "superuser", :role_id => adm.id)

  User.all.each { |u|
    Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id)
  }

end
