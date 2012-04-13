g = Group.sns_group

g.users.each do |u|
  unless u.active_member?
    print "Removing #{u}.\n"
    g.positions.where(:user_id => u.id).each do |p|
      p.destroy
    end
  end
end

us = g.users(true)
role = Role.find_by_name("Member")

Position.where(["created_at > ?", 8.months.ago]).includes(:user).each do |p|
  u = p.user

  unless us.include? u
    print "Adding #{u}.\n"
    g.positions.create(:user_id => u.id, 
                       :role_id => role.id,
                       :display_name => "Member")
  end
end

us = g.users(true)
print "There are currently #{us.length} active members.\n"
