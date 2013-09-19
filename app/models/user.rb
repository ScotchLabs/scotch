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
	include Shared::Scheduling

  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence, :birthday, :headshot, :majors, :minors,
    :other_activities, :about, :andrewid, :public_profile, :email_notifications, :tech_skills,
    :google_access_token, :google_refresh_token

  has_many :positions, :dependent => :destroy
  has_many :groups, :through => :positions

  has_many :event_attendees, :dependent => :destroy
  has_many :events, :through => :event_attendees

  #Messaging
  has_settings
  has_and_belongs_to_many :message_threads
  has_many :messages
  
	Paperclip.interpolates :aid_initial do |attachment,style| 
		attachment.instance.andrewid.first
	end
	Paperclip.interpolates :andrew do |attachment,style| attachment.instance.andrewid end

  has_attachment :headshot, 
    :styles => {:medium => "150x150#", :thumb => "50x50#"},
    :default_url => '/assets/missing/:class_:style.png',
		:file_name => 'headshots/:aid_initial/:andrew_:style.:extension'

  validates_attachment_size :headshot, :less_than => 10.megabytes,
    :message => "must be less than 10 megabytes",
    :unless => lambda { |user| !user.headshot.nil? }
  validates_attachment_content_type :headshot,
    :content_type => ["image/jpeg", "image/gif", "image/png"],
    :message => "must be an image (JPEG, GIF or PNG)",
    :unless => lambda { |user| !user.headshot.nil? }  

  DEFAULT_PERMISSIONS = %w(createGroup)
  HOME_COLLEGES = %w(SCS CIT CFA MCS TSB SHS BXA DC Heinz)

  validates_presence_of :first_name, :last_name, :encrypted_password, :andrewid

  validates_length_of :phone, :minimum => 10, :allow_nil => true, :allow_blank => true

  validates_length_of :smc, :is => 4, :allow_nil => true, :allow_blank => true
  validates_numericality_of :smc, :only_integer => true, :allow_nil => true, :allow_blank => true

  validates_length_of :graduation_year, :is => 4, :allow_nil => true, :allow_blank => true
  validates_numericality_of :graduation_year, :only_integer => true, :allow_nil => true, :allow_blank => true

  validates_inclusion_of :home_college, in: HOME_COLLEGES, allow_nil: true, allow_blank: true
  
  before_validation :downcase_email

  scope :recent, unscoped.where(["current_sign_in_at > ?", 2.weeks.ago]).order("current_sign_in_at DESC").limit(10)
  scope :most_watched, unscoped.select("users.*, count(*) as watcher_count").joins(:watchers).group("users.id").order("watcher_count DESC").limit(10)
  scope :newest, unscoped.order("created_at DESC").limit(10)

  def self.search(query)
    where("concat_ws(' ',first_name,last_name) LIKE '%?%' OR andrewid LIKE '%s%' OR \
          email LIKE '%s%' OR phone LIKE '%s%'")
  end

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
    if self.andrewid.nil? and not e.nil? and e.include? "@andrew.cmu.edu"
      self.andrewid = e[0...e.index("@andrew.cmu.edu")]
    end
    self.email
  end
  
########################
# EXTENDED INFORMATION #
########################
  
  def active_member?
    self.positions.where{ created_at > 8.months.ago }.count > 0
  end

  def google_active?
    self.google_access_token && self.google_refresh_token
  end

  def google_auth
    {access_token: self.google_access_token, refresh_token: self.google_refresh_token}
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
    return true unless self.phone && self.home_college && self.graduation_year &&
      self.smc && self.gender && self.residence && self.birthday && self.headshot &&
      self.majors && self.about

    false
  end
  
  def age
    today = Date.today
    result = today.year - birthday.year
    result = result - 1 if birthday.month < today.month ||
      (birthday.month == today.month && birthday.day < today.day)

    result
  end

  def name
    first_name + " " + last_name
  end

#################################
# GROUPS AND POSITIONS METHODS #
#################################

  def active_groups
    self.groups.active
  end
  
  def active_positions
    self.positions
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
    self.groups.include? group
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
    self.events
  end

  def future_events
    self.events.future
  end

  # This is for use with the user's autocomplete view
  # It finds the user that corresponds to the identifier
  # currently the identifier we use is
  # FIRST LAST EMAIL
  def self.autocomplete_retreive_user(identifier)
    return nil if identifier.nil? || identifier.blank? ||
      identifier.split(" ").length < 3
    email = identifier.split(" ").last
    User.find_by_email(email)
  end

  def identifier
    "#{name} #{email}"
  end
  
  def notify(source, subject, action, text)
    if self.notifications.unread.where(subject_id: subject.id, subject_type: subject.class.to_s, action: action).count == 0
      self.notifications.create(source_id: source.id, source_type: source.class.to_s, subject_id: subject.id,
      subject_type: subject.class.to_s, action: action, text: text)
    end
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    user
  end
  
  protected

  def downcase_email
    self.email = self.email.downcase
  end
end
