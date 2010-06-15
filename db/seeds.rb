# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User.transaction do

  #Create roles
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

  #Create system group
  grp = Group.create(:name => "SYSTEM GROUP", 
                     :description => "System group for site wide privilages")

  adm = Role.create(:name => "Administrator", :group_type => "Group")
  p = Permission.create(:name => "superuser", :description => "User has ALL PRIVILAGES")
  su = RolePermission.create(:permission_id => p.id, :role_id => adm.id)

  #Create web team
  u = User.create(:email => "achivett@andrew.cmu.edu", :first_name => "Anthony",
              :last_name => "Chivetta", :password => "123456", 
              :phone => "(314) 791-6768", :smc => "2576", 
              :residence => "Roselawn 1", :home_college => "SCS", 
              :graduation_year => "2012", :gender => "Male")
  u.confirm! #if we don't do this, you can't log in :(
  pos = Position.create(:role_id => adm.id, :user_id => u.id, 
                  :display_name => "System Administrator")
  pos.group_id = grp.id
  pos.save!

  u = User.create(:email => "amgross@andrew.cmu.edu", :first_name => "Aaron",
              :last_name => "Gross", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  pos = Position.create(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

  u = User.create(:email => "dfreeman@andrew.cmu.edu", :first_name => "Daniel",
              :last_name => "Freeman", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  pos = Position.create(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

  u = User.create(:email => "jrfriedr@andrew.cmu.edu", :first_name => "Jasmine",
              :last_name => "Friedrich", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  pos = Position.create(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Design Mistress")
  pos.group_id = grp.id
  pos.save!

  u = User.create(:email => "mdickoff@andrew.cmu.edu", :first_name => "Matt",
              :last_name => "Dickoff", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  pos = Position.create(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

  u = User.create(:email => "sewillia@andrew.cmu.edu", :first_name => "Spencer",
              :last_name => "Williams", :password => "123456")
  u.confirm! #if we don't do this, you can't log in :(
  pos = Position.create(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

end

User.transaction do
  #Create Board
  g = Group.create(:name => "Board of Directors", 
                     :description => "Scotch'n'Soda Board of Directors")
  r = Role.create(:name => "Manager", :group_type => "Group")

  u = User.where(:email => "amgross@andrew.cmu.edu").first
  p = Position.create(:role_id => r.id, :user_id => u.id,
                  :display_name => "President")
  p.group_id = g.id
  p.save!

  u = User.where(:email => "achivett@andrew.cmu.edu").first
  p = Position.create(:role_id => r.id, :user_id => u.id,
                  :display_name => "Webmaster")
  p.group_id = g.id
  p.save!
end

User.transaction do
  b = Group.where(:name => "Board of Directors").first

  g = Show.create(:name => "Closer", :parent_id => b.id, 
                  :description => "This is a blurb about the show that will be pulled for the public web page.")
  r = Role.where(:name => "Production Staff").first

  u = User.where(:email => "achivett@andrew.cmu.edu").first
  p = Position.create(:role_id => r.id, :user_id => u.id, 
                  :display_name => "Technical Director")
  p.group_id = g.id
  p.save!
end
