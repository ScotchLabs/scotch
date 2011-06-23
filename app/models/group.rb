class Group < Shared::Watchable
	# Coerce Paperclip into using custom storage
	include Shared::AttachmentHelper

  has_many :checkouts, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :positions, :include => :user, :dependent => :destroy
  has_many :users, :through => :positions

  belongs_to :parent, :class_name => "Group"

	Paperclip.interpolates :groupname do |attachment,style| attachment.instance.short_name end

  has_attachment :image, :styles => 
    { :medium => "150x150#", :thumb => "50x50#" },
    :default_url => '/images/missing/:class_:style.png',
		:file_name => ':class/:groupname_:style.:extension'

  validates_attachment_size :image, :less_than => 10.megabytes,
    :message => "must be less than 10 megabytes",
    :unless => lambda { |group| !group.image.nil? }
  validates_attachment_content_type :image,
    :content_type => ["image/jpeg", "image/gif", "image/png"],
    :message => "must be an image (JPEG, GIF or PNG)",
		:unless => lambda { |group| !group.image.nil? }

  define_index do
    indexes :name
    indexes :description
    indexes :short_name
  end

  # I think names should be unique too, but that hasn't been the case
  validates_uniqueness_of :short_name
  validates_format_of :short_name, :with => /\A[0-9A-Za-z_&-_]{1,20}\Z/

  scope :active, where("(archive_date IS NULL) OR (archive_date > NOW())")
  scope :archived, where("(archive_date IS NOT NULL) AND (archive_date < NOW())")

  # sets model_name for all subclasses to be "Group"
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Group.model_name
      end
    end
    super
  end

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

  def self.sns_group
    g = Group.find(3)

    unless g and g.name == "Scotch'n'Soda"
      logger.warn "Did the SNS group change?"
    end
    
    return g
  end

  def roles
    self.class.roles
  end
  # Return all roles that are valid for this group.
  def self.roles
    return Role.where :group_type => self.name
  end

  # Return all permissions that a user has for this group.
  # FIXME: we use custom finder sql because i can't get rails to string the
  # joins together the way I want... Also, this won't climb all the way up the
  # tree of group, just to the first parent.
  def permissions_for(user)
    sql = "SELECT `permissions`.* FROM `permissions` 
      INNER JOIN `role_permissions` ON `permissions`.`id` = `role_permissions`.`permission_id` 
      INNER JOIN `roles` ON `role_permissions`.`role_id` = `roles`.`id` 
      INNER JOIN `positions` ON `roles`.`id` = `positions`.`role_id` 
      WHERE (`positions`.`user_id` = #{user.id})"
    if self.parent.nil?
      sql += " AND (`positions`.`group_id` = #{self.id});"
    else
      sql += " AND (`positions`.`group_id` IN (#{self.id},#{self.parent.id}));"
    end

    return Permission.find_by_sql(sql)
  end

  def user_has_permission?(user,permission)
    perms = permissions_for(user)
    perms.include?(permission) || perms.include?(Permission.fetch("superuser"))
  end

  def user_is_superuser?(user)
    perms = permissions_for(user)
    perms.include?(Permission.fetch("superuser"))
  end

  def to_s
    name
  end

  def manager_role
    self.class.manager_role
  end
  def self.manager_role
    Role.where(:name => "Administrator").first
  end

  def member_positions
    positions.group_by{|p| p.user}.collect{|u,ps| [u,ps.sort]}
  end

  def calendar_positions
    # this method provides the positions of a group, as filtered for the user selection form
    a=[]
    a.push({:name=>"Board of Directors",:positions=>Board.directors.positions.map{|e| e.simple}.compact})
    # if the group is a Board then all members are in some filter already
    # if the group is a Show then the following filters will be applied
    #   (this is the super call):
    #   role.name=~/Cast|Production Staff|Tech Head|Crew/
    if id != Board.directors.id
      p=positions.map{|e| e.simple}.compact.select{|e| e[:role] !~ /Cast|Crew|Production Staff|Tech Head/}
      roles = p.map{|e| e[:role]}.uniq
      for role in roles
        a.push(:name=>"#{role.pluralize}",:positions=>p.select{|e| e[:role]==role})
      end
    end
    return a
  end

	#TODO this isn't actually quite right for groups (I think)
  # but it works for shows and boards, which are what matter
	# for the moment.
	def school_year
		date = archive_date.nil? ? Date.today : archive_date

		if date.month < 7
			year = date.year - 1
		else
			year = date.year
		end
		Date.new(year,7,1)..Date.new(year+1,6,30)
	end

  def <=>(other)
    other_date = (other.archive_date or Date.today)
    me_date = (archive_date or Date.today)
    datesort = other_date <=> me_date
    if datesort == 0
      return name.downcase <=> other.name.downcase
    else
      return datesort
    end
  end

  def archived?
    archive_date && archive_date <= Date.today
  end
  def active?
    not self.archived?
  end

  def className
    "event_color_#{short_name.hash % 42}"
  end
end
