# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User.transaction do

  p = Permission.create(:name => "adminPositions", 
                        :description => "User may modify group membership at will")
  r = Role.create(:name => "Production Staff", :group_type => "Show")
  RolePermission.create(:permission_id => p.id, :role_id => r.id);

  p = Permission.create(:name => "adminCrew",
                        :description => "User may modify group membership with crew role at will")
  r = Role.create(:name => "Tech Head", :group_type => "Show")
  RolePermission.create(:permission_id => p.id, :role_id => r.id)

  Role.create(:name => "Crew", :group_type => "Show")
  Role.create(:name => "Cast", :group_type => "Show")
  Role.create(:name => "Member", :group_type => "Group")

  grp = Group.create(:id => 1, :name => "SYSTEM GROUP", 
                     :description => "System group for site wide privilages")
  adm = Role.create(:name => "Administrator", :group_type => "Group")
  p = Permission.create(:name => "superuser", :description => "User has ALL PRIVILAGES")
  su = RolePermission.create(:permission_id => p.id, :role_id => adm.id)

  u = User.create(:email => "achivett@andrew.cmu.edu", :first_name => "Anthony",
              :last_name => "Chivetta", :password => "123456", 
              :phone => "(314) 791-6768", :smc => "2576", 
              :residence => "Roselawn 1", :home_college => "SCS", 
              :graduation_year => "2012", :gender => "Male")
  u.confirm! #if we don't do this, you can't log in :(
  Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id, 
                  :display_name => "System Administrator")

  u = User.create(:email => "amgross@andrew.cmu.edu", :first_name => "Aaron",
              :last_name => "Gross", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")

  u = User.create(:email => "dfreeman@andrew.cmu.edu", :first_name => "Daniel",
              :last_name => "Freeman", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")

  u = User.create(:email => "jrfriedr@andrew.cmu.edu", :first_name => "Jasmine",
              :last_name => "Friedrich", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id,
                  :display_name => "Design Mistress")

  u = User.create(:email => "mdickoff@andrew.cmu.edu", :first_name => "Matt",
              :last_name => "Dickoff", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")

  u = User.create(:email => "sewillia@andrew.cmu.edu", :first_name => "Spencer",
              :last_name => "Williams", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  Position.create(:group_id => grp.id, :role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")

end
