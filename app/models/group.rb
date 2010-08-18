class Group < ActiveRecord::Base

  has_many :checkouts, :dependent => :destroy
  has_many :documents
  has_many :events, :dependent => :destroy
  has_many :positions
  has_many :users, :through => :positions

  belongs_to :parent, :class_name => "Group"

  has_attached_file :image, :styles => { :medium => "200x200>", :thumb => "75x75>" },
    :default_url => '/images/missing_image.jpg'

  # I think names should be unique too, but that hasn't been the case
  validates_uniqueness_of :short_name
  validates_format_of :short_name, :with => /\A[0-9A-Za-z_&-_]{1,20}\Z/

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

    return perms
  end

  def user_has_permission?(user,permission)
    permissions_for(user).include?(permission)||
      permissions_for(user).include?(Permission.fetch("superuser"))
  end

  def to_s
    name
  end

  def self.manager_role
    Role.where(:name => "Administrator").first
  end

  def member_positions
    positions.group_by{|p| p.user}.collect{|u,ps| [u,ps.sort]}
  end

  def <=>(other)
    other_date = (other.archive_date or Date.today)
    me_date = (archive_date or Date.today)
    other_date <=> me_date
  end

  def archived?
    archive_date && archive_date < Date.today
  end
  def active?
    not self.archived?
  end
end
