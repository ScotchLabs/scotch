# == Schema Information
#
# Table name: users
#
#  id                    :integer(4)      not null, primary key
#  email                 :string(255)     default(""), not null
#  encrypted_password    :string(128)     default(""), not null
#  password_salt         :string(255)
#  confirmation_token    :string(255)
#  confirmed_at          :datetime
#  confirmation_sent_at  :datetime
#  reset_password_token  :string(255)
#  remember_token        :string(255)
#  remember_created_at   :datetime
#  sign_in_count         :integer(4)      default(0)
#  current_sign_in_at    :datetime
#  last_sign_in_at       :datetime
#  current_sign_in_ip    :string(255)
#  last_sign_in_ip       :string(255)
#  first_name            :string(255)
#  last_name             :string(255)
#  status                :string(255)
#  authentication_token  :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  phone                 :string(255)
#  home_college          :string(255)
#  smc                   :string(255)
#  graduation_year       :string(255)
#  residence             :string(255)
#  gender                :string(255)
#  birthday              :date
#  public_profile        :boolean(1)      default(TRUE), not null
#  headshot_file_name    :string(255)
#  headshot_content_type :string(255)
#  headshot_file_size    :integer(4)
#  headshot_updated_at   :datetime
#  andrewid              :string(255)
#  majors                :string(255)
#  minors                :string(255)
#  other_activities      :string(255)
#  about                 :text
#  email_notifications   :boolean(1)      default(TRUE), not null
#

class User < Shared::Watchable
  # Coerce Paperclip into using custom storage
	include Shared::AttachmentHelper

  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence, :birthday, :headshot, :majors, :minors,
    :other_activities, :about, :andrewid

  has_many :positions, :dependent => :destroy
  has_many :groups, :through => :positions

  has_many :event_attendees, :dependent => :destroy
  has_many :events, :through => :event_attendees

  has_many :checkouts
  
  has_many :watchees, :class_name => "Watcher", :dependent => :destroy

  #FIXME use :source_type instead of :conditions
  has_many :watched_items, :through => :watchees, :source => :watched_item, 
    :conditions => "watchers.item_type = 'Item'"
  has_many :watched_users, :through => :watchees, :source => :watched_user, 
    :conditions => "watchers.item_type = 'User'"
  has_many :watched_groups, :through => :watchees, :source => :watched_group, 
    :conditions => "watchers.item_type = 'Group' OR watchers.item_type = 'Board' OR watchers.item_type = 'Show'"

  #FIXME these don't work STUPID RAILS
  #has_many :watched_item_feedposts, :through => :watched_items, :source => :feedposts
  #has_many :watched_user_feedposts, :through => :watched_users, :source => :feedposts
  #has_many :watched_group_feedposts, :through => :watched_groups, :source => :feedposts

	Paperclip.interpolates :aid_initial do |attachment,style| 
		attachment.instance.andrewid.first
	end
	Paperclip.interpolates :andrew do |attachment,style| attachment.instance.andrewid end

  has_attachment :headshot, 
    :styles => {:medium => "150x150#", :thumb => "50x50#"},
    :default_url => '/images/missing/:class_:style.png',
		:file_name => 'headshots/:aid_initial/:andrew_:style.:extension'

  validates_attachment_size :headshot, :less_than => 10.megabytes,
    :message => "must be less than 10 megabytes",
    :unless => lambda { |user| !user.headshot.nil? }
  validates_attachment_content_type :headshot,
    :content_type => ["image/jpeg", "image/gif", "image/png"],
    :message => "must be an image (JPEG, GIF or PNG)",
    :unless => lambda { |user| !user.headshot.nil? }  

  define_index do
    indexes :email
    indexes :first_name
    indexes :last_name
    indexes :phone
    indexes :residence
    indexes :andrewid
    indexes :majors
    indexes :minors
    indexes :other_activities
    indexes :about

    where 'public_profile = 1'
  end

  validates_presence_of :first_name, :last_name, :encrypted_password, :andrewid

  validates_length_of :phone, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_length_of :residence, :minimum => 3, :allow_nil => true, :allow_blank => true

  validates_length_of :smc, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_numericality_of :smc, :only_integer => true, :allow_nil => true, :allow_blank => true
  validates_length_of :graduation_year, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_numericality_of :graduation_year, :only_integer => true, :allow_nil => true, :allow_blank => true
  
  acts_as_phone_number :phone
  before_validation :downcase_email
  after_create :create_watcher
  after_create :create_sns_membership

  DEFAULT_PERMISSIONS = %w(createGroup)
  HOME_COLLEGES = %w(SCS H&SS CIT CFA MCS TSB SHS BXA)

  scope :recent, unscoped.where(["current_sign_in_at > ?", 2.weeks.ago]).order("current_sign_in_at DESC").limit(10)
  scope :most_watched, unscoped.select("users.*, count(*) as watcher_count").joins(:watchers).group("users.id").order("watcher_count DESC").limit(10)
  scope :newest, unscoped.order("created_at DESC").limit(10)
  scope :birthday, where(:birthday => (1..100).to_a.collect{|n|n.years.ago.to_date})

####################
# OBJECT OVERRIDES #
####################

  def to_s 
    name
  end
  
  def to_param
    andrewid
  end
  
  def <=>(other)
    (last_name + first_name)<=>(other.last_name + other.first_name)
  end
  
###################
# TABLE OVERRIDES #
###################

  def andrewid=(a)
    unless self.andrewid.nil?
      begin
        logger.warn "Someone tried to set #{self.name}'s andrew id, but it's not nil"
      rescue NoMethodError
        logger.warn "Someone tried to set an andrew id for #{self.inspect}."
      end
      return
    end
    super
    self.email="#{andrewid}@andrew.cmu.edu"
    self.andrewid
  end
  
  def email=(e)
    super
    if self.andrewid.nil? and e.include? "@andrew.cmu.edu"
      self.andrewid = e[0...e.index("@andrew.cmu.edu")]
    end
    self.email
  end
  
########################
# EXTENDED INFORMATION #
########################
  
  def active_member?
    # what constitutes an active member?
    # being in a position right now
    return true unless positions.empty?
    # being in a position for a show within the past year
    #TODO
  end

  # Get school years (actually Date ranges) in which the user
  # was active -- optionally takes a parameter only to count
  # positions in a specific type of group 
  def active_years(type = ["Show", "Board"])
    years = []
    groups.where(:type => type).each do |g|
      current = g.school_year
      years <<= current unless years.include? current
    end
    years.sort { |a,b| a.first <=> b.first }
  end

  def incomplete_record?
    return true unless self.phone and self.home_college and self.graduation_year \
      and self.smc and self.gender and self.residence and self.birthday and self.headshot \
      and self.majors and self.about
    false
  end
  
  def age
    ((Date.today - birthday)/365.2422).to_i unless birthday.nil?
  end

  def name
    (first_name or "") + " " + (last_name or "")
  end

#################################
# GROUPS AND POSITIONS METHODS #
#################################

  def active_groups
    self.groups.all.select{|g| g.active?}
  end
  
  def active_positions
    positions.select{ |p| p.group.active? }
  end
 
  def positions_during(timespan, type = nil)
    conditions = {"groups.archive_date" => timespan}
    conditions["groups.type"] = type unless type.nil?
    positions.joins(:group).where(conditions)
  end 
  
  def recent_groups(count)
  	group_ids = self.positions.select("DISTINCT group_id").order("group_id DESC").map{ |p| p.group_id }
	groups = Group.where(:id => group_ids).where("(archive_date IS NULL) OR (archive_date > NOW())").order("id DESC").limit(count)
	groups.concat(Group.where(:id => group_ids).where("(archive_date IS NOT NULL) AND (archive_date < NOW())").order("id DESC").limit(count - groups.length))
	return groups
  end

  def member_of?(group)
    self.groups.include(group)
  end
 
#######################
# PERMISSIONS METHODS #
#######################

  def global_permissions
    Group.system_group.permissions_for(self) +
      DEFAULT_PERMISSIONS.collect {|p| Permission.fetch(p)}
  end

  def has_global_permission?(permission)
    global_permissions.include?(permission) ||
      global_permissions.include?(Permission.fetch("superuser"))
  end

  def superuser?
    global_permissions.include?(Permission.fetch("superuser"))
  end

#################
# EVENT METHODS #
#################

  # All events which should appear on the user's calendar
  def user_events
    es = events.all
    es += Event.where(:group_id => groups.collect{|g| g.id}).select{|e| e.event_attendees.count == 0}
    return es
  end

  def future_events
    es = events.future.all 
    es += Event.future.where(:group_id => groups.collect{|g| g.id}).select{|e| e.event_attendees.count == 0}
    return es
  end

###################
# WATCHER METHODS #
###################

  def following? (object)
    return false if object.nil?
    return watchees.where(:item_type => object.class.to_s.classify.constantize.base_class.to_s).where(:item_id => object.id).count >= 1
  end

  def watcher_for (object)
    return nil if object.nil?
    # FIXME this is ugly, and there are a bunch of places where we have to do
    # it...
    return watchees.where(:item_type => object.class.to_s.classify.constantize.base_class.to_s).where(:item_id => object.id).first
  end

  def recent_feed_entries
    groups = self.watched_groups
    items = self.watched_items
    users = self.watched_users

    group_posts = Feedpost.recent.where(:parent_type => "Group").where(:parent_id => groups.collect{|g|g.id}).includes(:user).all
    item_posts = Feedpost.recent.where(:parent_type => "Item").where(:parent_id => items.collect{|i|i.id}).includes(:user).all
    user_posts = Feedpost.recent.where(:parent_type => "User").where(:parent_id => users.collect{|u|u.id}).includes(:user).all

    (group_posts + item_posts + user_posts).sort.reverse
  end

  # This is for use with the user's autocomplete view
  # It finds the user that corresponds to the identifier
  # currently the identifier we use is
  # FIRST LAST EMAIL
  def self.autocomplete_retreive_user(identifier)
    return nil if identifier.nil? or identifier.blank?
    return nil if identifier.split(" ").length < 3
    email = identifier.split(" ").last
    User.find_by_email(email)
  end

  protected

  def create_watcher
    w = Watcher.new
    w.user = self
    w.item = self
    w.save or logger.warn "Unable to save implicitly created watcher"
  end

  def create_sns_membership
    member_role = Role.member
    p = Position.new(:role_id => member_role.id, :display_name => "Member", :user_id => self.id)
    p.group_id = Group.sns_group.id
    p.save or logger.warn "Unable to save implicitly created position"
  end

  def downcase_email
    self.email = self.email.downcase
  end
end
