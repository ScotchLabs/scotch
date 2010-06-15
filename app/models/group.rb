class Group < ActiveRecord::Base

  has_many :checkouts
  has_many :documents
  has_many :events
  has_many :positions
  has_many :users, :through => :positions

  belongs_to :parent, :class_name => "Group"

  # Return the system group, a "special" group defined as having an ID of 1.
  # The system group is used to assign permissions to the webmaster and other
  # extraordinary users that enable them to access admin/ and do other
  # back-end tasks. 
  def self.system_group
    return Group.find(1)
  end

  # Return all roles that are valid for this group.
  def roles
    return Role.where(["group_type = ?",self.class.name]).all
  end

  # Return all permissions that a user has for this group.  This is calculated
  # by climbing up the tree of groups that are parent to this one.  This isn't
  # a cheep operation :(.  For this reason TODO CACHE THIS FUNCTION.  At least
  # I didn't decide to make roles have parents too!
  def permissions_for(user)
    perms = []

    positions.where(:user_id => user.id).each do |p|
      perms << p.role.permissions
    end

    if (parent) then
      return (perms + parent.permissions_for(user)).uniq
    else
      return perms.uniq
    end
  end

  def user_has_permission?(user,permName)
    permissions_for(user).include? Permission.get(permName) ||
      permissions_for(user).include? Permission.get("superuser")
  end

  def to_s
    name
  end

end
