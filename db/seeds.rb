# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require 'xml'

# Some things are already html encoded
coder = HTMLEntities.new

# read xml file of old data
gz = Zlib::GzipReader.open('db/prod.xml.gz')
xml = gz.read
gz.close

# parse the file
parser, parser.string = XML::Parser.new, xml
doc = parser.parse

#create magical groups
Group.transaction do
  g = Board.create(:name => "SYSTEM GROUP", :short_name => "SYSTEM",
                     :description => "System group for site wide privileges")
  g.save!

  g = Board.create(:name => "Board of Directors", :short_name => "Board",
                   :description => "Scotch'n'Soda Board of Directors")
  g.save!

  g = Group.create(:name => "Scotch'n'Soda", :short_name => "sns", :parent_id => g.id,
                   :description => "Scotch'n'Soda wide group.  Users are added to this group automatically when they join Scotch.  Stay a member of this group if you want to get Scotch'n'Soda-wide communications.")
  g.save!
end

#create permissions
Permission.transaction do
  Permission.create(:name => "adminPositions", 
                    :description => "User may modify group membership at will.  Any role granted this permission should also be granted adminCrew.")
  Permission.create(:name => "adminCrew",
                    :description => "User may modify group membership with crew role at will")
  Permission.create(:name => "adminEvents",
                    :description => "User may create/modify/delete events and change event attendees")
  Permission.create(:name => "adminGroup",
                    :description => "User may change basic group information")
  Permission.create(:name => "adminDocuments",
                    :description => "User may modify documents at will")

  Permission.create(:name => "checkoutSelf", :description => "User may check out items to self and group or groups self is in")
  Permission.create(:name => "checkoutOther", :description => "User may check out item to group or any group and group users or any group's users")
  Permission.create(:name => "email", :description => "User can email group members")

  #Global Permissions
  Permission.create(:name => "superuser", :description => "User has ALL PRIVILEGES")
  Permission.create(:name => "createGroup", :description => "GLOBAL: User can create generic Groups")
  Permission.create(:name => "createShow", :description => "GLOBAL: User can create Shows")
  Permission.create(:name => "createBoard", :description => "GLOBAL: User can create Boards")
  Permission.create(:name => "archiveGroup", :description => "User can archive a group")
  Permission.create(:name => "adminHelpItems", :description => "GLOBAL: User can edit HelpItems")
  Permission.create(:name => "adminItemCategories", :description => "GLOBAL: User can edit ItemCategories")
  Permission.create(:name => "adminItems", :description => "GLOBAL: User can edit items")
  Permission.create(:name => "adminRoles", :description => "GLOBAL: User can edit available roles")
  Permission.create(:name => "adminUsers", :description => "GLOBAL: User can edit all users in the system")
end

# create roles
Role.transaction do
  # Shows
  r = Role.create(:name => "Production Staff", :group_type => "Show")
  p = Permission.fetch("superuser")
  RolePermission.create(:permission_id => p.id, :role_id => r.id);

  r = Role.create(:name => "Tech Head", :group_type => "Show")
  p = Permission.fetch("adminCrew")
  RolePermission.create(:permission_id => p.id, :role_id => r.id)
  p = Permission.fetch("adminEvents")
  RolePermission.create(:permission_id => p.id, :role_id => r.id);
  p = Permission.fetch("email")
  RolePermission.create(:permission_id => p.id, :role_id => r.id);

  Role.create(:name => "Crew", :group_type => "Show")
  Role.create(:name => "Cast", :group_type => "Show")

  # Groups
  adm = Role.create(:name => "Administrator", :group_type => "Group")
  p = Permission.fetch("superuser")
  RolePermission.create(:permission_id => p.id, :role_id => adm.id)

  Role.create(:name => "Member", :group_type => "Group")

  # Boards
  r = Role.create(:name => "Head", :group_type => "Board")
  p = Permission.fetch("superuser")
  RolePermission.create(:permission_id => p.id, :role_id => r.id)
end

member_role = Role.find_by_name("Member")
head_role = Board.manager_role
sns_group = Group.find_by_short_name("sns")
board_group = Group.find_by_short_name("Board")

#import users
doc.find("//users").each do |s|
  email = s.find("email").first.content.downcase
  email = "jrfriedr@andrew.cmu.edu" if email == "jasmine@cmu.edu"
  first_name = s.find("firstname").first.content
  last_name = s.find("lastname").first.content
  password = s.find("password").first.content
  password_salt = password[0..31]
  encrypted_password = password[32..159]

  #<boardpos>Vice President</boardpos>
  board_position = s.find("boardpos").first.nil? ? nil : s.find("boardpos").first.content

  phone = s.find("phone").first.content
  smc = s.find("smc").first.content
  residence = s.find("residence").first.content
  home_college = s.find("homecoll").first.content
  graduation_year = s.find("gradyear").first.content
  gender = "Male" if s.find("ismale").first.content == "1"
  gender = "Female" if s.find("ismale").first.content == "0"

  smc = nil if smc == "0"
  graduation_year = nil if graduation_year == "0"

  public_profile = (s.find("privphone").first.content == "1") and
                   (s.find("privhomecoll").first.content == "1") and
                   (s.find("privsmc").first.content == "1") and
                   (s.find("privresidence").first.content == "1") and
                   (s.find("privgradyear").first.content == "1")

  u = User.new(:email => email, :first_name => first_name, :last_name => last_name,
           :phone => phone, :smc => smc, :residence => residence,
           :home_college => home_college, :graduation_year => graduation_year,
           :gender => gender, :public_profile => public_profile, :password => "123456")
  u.encrypted_password = encrypted_password
  u.password_salt = password_salt
  u.skip_confirmation!
  u.confirm!
  unless u.save
    puts "Unable to save user #{email}:" 
    u.errors.each_full { |msg| puts " " + msg }
  else
    p = Position.new(:role_id => member_role.id, :display_name => "Member", :user_id => u.id)
    p.group_id = sns_group.id
    p.save!

    if board_position
      puts "creating board position #{board_position} for #{u}"
      p = Position.new(:role_id => head_role.id, :user_id => u.id,
                          :display_name => board_position)
      p.group_id = board_group.id
      p.save!
    end
  end
end

#create system group and system users
User.transaction do
  adm = head_role
  grp = Group.system_group

  #Create web team
  u = User.find_by_email("achivett@andrew.cmu.edu")
  pos = Position.new(:role_id => adm.id, :user_id => u.id, 
                  :display_name => "Webmaster")
  pos.group_id = grp.id
  pos.save!

  u = User.find_by_email("amgross@andrew.cmu.edu")
  pos = Position.new(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

  u = User.find_by_email("dfreeman@andrew.cmu.edu")
  pos = Position.new(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

  u = User.find_by_email("jrfriedr@andrew.cmu.edu")
  pos = Position.new(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Design Mistress")
  pos.group_id = grp.id
  pos.save!

  u = User.find_by_email("mdickoff@andrew.cmu.edu")
  pos = Position.new(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!

  u = User.find_by_email("sewillia@andrew.cmu.edu")
  pos = Position.new(:role_id => adm.id, :user_id => u.id,
                  :display_name => "Developer")
  pos.group_id = grp.id
  pos.save!
end

HelpItem.transaction do
    HelpItem.create(:name => "SMC", :anchor => "why-smc", :display_text => "why?",
      :message => "Occasionally, we'll have our members make purchases for Scotch'N'Soda themselves and reimburse them.  When we do this, we need to know the member's SMC to deliver the reimbursement check.")
    HelpItem.create(:name => "Phone Number", :anchor => "why-phone", :display_text => "why?",
      :message => "-Sometimes- At least 2463 times a day during a show, someone important needs to call someone else important. So if you ever want to be important it's a good idea to make your phone number available.")
    HelpItem.create(:name => "Textile", :anchor => "textile", :display_text => "Textile",
      :message => "[\"RedCloth\":http://redcloth.org/]  enables us to use the [\"Textile markup language\":http://en.wikipedia.org/wiki/Textile_(markup_language)]. Here are some examples of how to format certain things ([\"full manual\":http://redcloth.org/textile/]):

<notextile><pre>h1. Foo  -> creates an h1 element
h2. Bar  -> creates an h2 element
_word_   -> italics
*word*   -> bold
-word-   -> strikethrough
+word+   -> underline
@word@   -> code
==word== -> word will not be textiled
# item1  -> ordered list item
* item1  -> unordered list item</pre></notextile>")
end

#import categories
doc.find("//categories").each do |s|
  number = s.find("number").first.content.to_i
  name = s.find("name").first.content
  item = ItemCategory.new(:prefix => number, :name => name)
  item.save!
end

#import subcategories
doc.find("//subcategories").each do |s|
  number = s.find("number").first.content.to_i
  name = s.find("name").first.content
  parentid = s.find("broadid").first.content.to_i
  parent = ItemCategory.parent_categories.where(:prefix => parentid).first
  item = ItemCategory.new(:prefix => (number % 100), :name => name, :parent_category_id => parent.id)
  item.save!
end

#import items
item_categories_hash = Hash.new
ItemCategory.all.each { |i| item_categories_hash[i.slug.to_i] = i.id }
doc.find("//inventory").each do |s|
  name = s.find("itemname").first.content
  location = s.find("location").first.content
  description = coder.decode(s.find("description").first.content)

  itemnum = s.find("itemnum").first.content
  suffix = itemnum.length >= 3 ? itemnum[-3..-1].to_i : itemnum.to_i

  item_category_id = item_categories_hash[s.find("category").first.content.to_i]
  item = Item.new(:name => name, :location => location, :description => description,
                  :suffix => suffix, :item_category_id => item_category_id)
  item.save!
end

#import shows
doc.find("//shows").each do |s|
  name = s.find_first("showname").content
  short_name = s.find_first("showabbrev").content.gsub(/ /,"_")
  archive_date = Date.parse(s.find_first("strikedate").content)
  unless s.find_first("showdesc").nil?
    description = coder.decode(s.find_first("showdesc").content)
    description += "\n\nAuthor: " + coder.decode(s.find_first("showauth").content) if s.find_first("showauth")
    description += "\nShow Times: " + coder.decode(s.find_first("showtimes").content) if s.find_first("showtimes")
  else
    description = nil
  end

  puts "creating show #{name} (#{short_name})"

  g = Show.new(:name => name, :short_name => short_name, :archive_date => archive_date,
               :description => description)
  g.save!

  # Yay, xpath, FTW!
  doc.find("//staff[shownum/text()=\"#{s.find_first("shownum").content}\"]").each do |p|
    display_name = p.find_first("position").content

    if ["Choreographer", "Director", "Music Director", "Production Liaison", "Production Manager", "Stage Manager", "Stage Manager (2)", "Technical Director"].include? display_name.gsub(/Assistant /,"") then
      role = Role.find_by_name("Production Staff")
    elsif display_name =~ /Crew/ then
      role = Role.find_by_name("Crew")
    elsif p.find_first("key").content == "act" then
      role = Role.find_by_name("Cast")
    else
      role = Role.find_by_name("Tech Head")
    end

    user = User.find_by_email(p.find_first("andrewid").content + "@andrew.cmu.edu")

    if user
      p = Position.new(:role_id => role.id, :user_id => user.id,
                 :display_name => display_name)
      p.group_id = g.id
      unless p.save
        puts "Unable to save user #{email}:" 
        u.errors.each_full { |msg| puts " " + msg }
      end
    end
  end
end
