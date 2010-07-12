class Group < ActiveRecord::Base

  has_many :checkouts, :dependent => :destroy
  has_many :documents
  has_many :events, :dependent => :destroy
  has_many :positions
  has_many :users, :through => :positions

  belongs_to :parent, :class_name => "Group"

  validates_uniqueness_of :name

  # Return the system group, a "special" group defined as having an ID of 1.
  # The system group is used to assign permissions to the webmaster and other
  # extraordinary users that enable them to access admin/ and do other
  # back-end tasks. 
  def self.system_group
    g = Group.find(1)

    unless g.name == "SYSTEM GROUP"
      raise "Did the system group change?"
    end
    
    return g
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
      perms += p.role.permissions
    end

    perms = (perms += parent.permissions_for(user)) if (parent)
    perms.uniq!

    logger.info "user #{user} granted permissions #{perms.inspect} for group #{self}"
    return perms
  end

  def user_has_permission?(user,permission)
    permissions_for(user).include?(permission)||
      permissions_for(user).include?(Permission.fetch("superuser"))
  end

  def to_s
    name
  end

end
