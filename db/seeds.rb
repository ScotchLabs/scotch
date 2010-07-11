# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

#create permissions
Permission.transaction do
  Permission.create(:name => "adminPositions", 
                    :description => "User may modify group membership at will")
  Permission.create(:name => "adminCrew",
                    :description => "User may modify group membership with crew role at will")
  Permission.create(:name => "adminEvents",
                    :description => "User may create/modify/delete events and change event attendees")
  Permission.create(:name => "superuser", :description => "User has ALL PRIVILAGES")
  Permission.create(:name => "createGroup", :description => "User can create generic Groups")
  Permission.create(:name => "createBoard", :description => "User can create Boards")
  Permission.create(:name => "createShow", :description => "User can create Shows")
end

#create system group and system users
User.transaction do

  #Create roles
  p = Permission.fetch("adminPositions")
  r = Role.create(:name => "Production Staff", :group_type => "Show")
  RolePermission.create(:permission_id => p.id, :role_id => r.id);

  p = Permission.fetch("adminCrew")
  r = Role.create(:name => "Tech Head", :group_type => "Show")
  RolePermission.create(:permission_id => p.id, :role_id => r.id)

  Role.create(:name => "Crew", :group_type => "Show")
  Role.create(:name => "Cast", :group_type => "Show")
  Role.create(:name => "Member", :group_type => "Group")

  #Create system group
  grp = Group.create(:name => "SYSTEM GROUP", 
                     :description => "System group for site wide privilages")

  adm = Role.create(:name => "Administrator", :group_type => "Group")
  p = Permission.fetch("superuser")
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

#Create Board
Group.transaction do
  g = Board.create(:name => "Board of Directors", 
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

#Create DEMO show FIXME
User.transaction do
  g = Show.create(:name => "Some Show",
                  :description => "This is a blurb about the show that will be pulled for the public web page.")
  r = Role.where(:name => "Production Staff").first

  u = User.where(:email => "achivett@andrew.cmu.edu").first
  p = Position.create(:role_id => r.id, :user_id => u.id, 
                  :display_name => "Technical Director")
  p.group_id = g.id
  p.save!

  u = User.where(:email => "amgross@andrew.cmu.edu").first
  r = Role.where(:name => "Tech Head").first
  p = Position.create(:role_id => r.id, :user_id => u.id,
                      :display_name => "Lighting Designer")
  p.group_id = g.id
  p.save!

  u = User.where(:email => "dfreeman@andrew.cmu.edu").first
  r = Role.where(:name => "Crew").first
  p = Position.create(:role_id => r.id, :user_id => u.id,
                      :display_name => "Lighting Cnew")
  p.group_id = g.id
  p.save!

  p = Position.create(:role_id => r.id, :user_id => u.id,
                      :display_name => "Electrics Cnew")
  p.group_id = g.id
  p.save!

  u = User.where(:email => "sewillia@andrew.cmu.edu").first
  p = Position.create(:role_id => r.id, :user_id => u.id,
                      :display_name => "Lighting Cnew")
  p.group_id = g.id
  p.save!
  p = Position.create(:role_id => r.id, :user_id => u.id,
                      :display_name => "Electrics Cnew")
  p.group_id = g.id
  p.save!

  u = User.where(:email => "jrfriedr@andrew.cmu.edu").first
  r = Role.where(:name => "Tech Head").first
  p = Position.create(:role_id => r.id, :user_id => u.id,
                      :display_name => "Projectionist")
  p.group_id = g.id
  p.save!

  e = Event.create(:title => "Audition",
                   :start_time => 200.hours.ago, :end_time => 199.hours.ago,
                   :location => "PH 100");
  e.group_id = g.id
  e.save!
  ea = EventAttendee.create(:event_id => e.id, :user_id => u.id)
  ea = EventAttendee.create(:event_id => e.id)

  e = Event.create(:title => "Audition",
                   :start_time => 199.hours.ago, :end_time => 198.hours.ago,
                   :location => "PH 100");
  e.group_id = g.id
  e.save!
  ea = EventAttendee.create(:event_id => e.id)
  ea = EventAttendee.create(:event_id => e.id, :user_id => u.id)
  ea = EventAttendee.create(:event_id => e.id)

  e = Event.create(:title => "Audition",
                   :start_time => 198.hours.ago, :end_time => 197.hours.ago,
                   :location => "PH 100");
  e.group_id = g.id
  e.save!
  ea = EventAttendee.create(:event_id => e.id)
  ea = EventAttendee.create(:event_id => e.id)

  e = Event.create(:title => "Tech Interest",
                   :start_time => 100.hours.ago, :end_time => 99.hours.ago,
                   :location => "PH 100");
  e.group_id = g.id
  e.save!

  e = Event.create(:title => "Rehearsal",
                   :start_time => 10.hours.ago, :end_time => 9.hours.ago,
                   :location => "PH 100");
  e.group_id = g.id
  e.save!

  e = Event.create(:title => "Tech Rehearsal",
                   :start_time => 10.hours.since, :end_time => 11.hours.since,
                   :location => "McConomy");
  e.group_id = g.id
  e.save!

  e = Event.create(:title => "Performance",
                   :start_time => 100.hours.since, :end_time => 101.hours.since,
                   :location => "McConomy");
  e.group_id = g.id
  e.save!

  e = Event.create(:title => "Performance",
                   :start_time => 120.hours.since, :end_time => 121.hours.since,
                   :location => "McConomy");
  e.group_id = g.id
  e.save!
end

#Create ItemCategories from current SotW
ItemCategory.transaction do
  p = ItemCategory.create(:prefix => 0, :name => "Office Equipment")
  ItemCategory.create(:prefix => 0, :name => "Electronics", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Finance", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Library and Archives", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "Furniture", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "Office Supplies", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Office", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 1, :name => "Carpentry")
  ItemCategory.create(:prefix => 0, :name => "Power Tools", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Non-Power Tools", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Flats", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "Doors", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "Platforms", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Carpentry", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 2, :name => "Paint")
  ItemCategory.create(:prefix => 0, :name => "Stage Paint", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Fence Paint", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Painting Equipment", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Paint", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 3, :name => "Sound")
  ItemCategory.create(:prefix => 1, :name => "Speakers/Stands", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Sound Board", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "Mic ELements", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "Mic Packs", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 5, :name => "Cables and Adapters", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 6, :name => "Clearcom", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Sound", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 4, :name => "Lighting")
  ItemCategory.create(:prefix => 0, :name => "Instruments", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Barrels", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Instrument Accessories", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "Lighting Consoles", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "Power/Electrics Capital", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 5, :name => "LC and DMX Cable", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 6, :name => "Trees and Bases", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 7, :name => "Gel Material", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 8, :name => "Lamps", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Lighting", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 5, :name => "Costumes")
  ItemCategory.create(:prefix => 0, :name => "Capital Equipment", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Classical", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Medieval", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "16th Century", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "17th Century", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 5, :name => "18th Century", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 6, :name => "19th Century", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 7, :name => "1900s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 8, :name => "1910s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 9, :name => "1920s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 10, :name => "1930s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 11, :name => "1940s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 12, :name => "1950s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 13, :name => "1960s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 14, :name => "1970s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 15, :name => "1980s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 16, :name => "1990s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 17, :name => "2000s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 18, :name => "2010s", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 19, :name => "Arabia", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 20, :name => "Sequined", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 21, :name => "Suits", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 96, :name => "Accessories", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 97, :name => "Pantomime/Animals", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 98, :name => "Uniforms", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Costumes", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 6, :name => "Props")
  ItemCategory.create(:prefix => 0, :name => "Bedroom", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Living Room", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Kitchen - Ceramics", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "Kitchen - Glassware", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "Kitchen - Cooking Supplies", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 5, :name => "Kitchen - Plasticware", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 6, :name => "Kitchen - Serving Items", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 7, :name => "Kitchen - Misc", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 8, :name => "Bathroom", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 9, :name => "Outdoors", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 10, :name => "Office Supplies", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 11, :name => "Toys", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 12, :name => "Practical", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 13, :name => "Accessories", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Props", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 7, :name => "Hair/Makeup")
  ItemCategory.create(:prefix => 99, :name => "Misc. Hair/Makeup", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 8, :name => "Mixed Use")
  ItemCategory.create(:prefix => 0, :name => "Dungeon Carts", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 1, :name => "Edison Extension Cords", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 2, :name => "Curtains", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 3, :name => "Cleaning Supplies", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 4, :name => "Storage Boxes", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Misc. Mixed Use", :parent_category_id => p.id)
  
  p = ItemCategory.create(:prefix => 9, :name => "Miscellaneous")
  ItemCategory.create(:prefix => 0, :name => "ABTech Shared Equipment", :parent_category_id => p.id)
  ItemCategory.create(:prefix => 99, :name => "Miscellaneous", :parent_category_id => p.id)
end
