class User < ActiveRecord::Base
  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence, :birthday, :andrew_id, :headshot, :majors, :minors,
    :other_activities

  has_many :positions
  has_many :groups, :through => :positions

  has_many :event_attendees, :dependent => :destroy
  has_many :events, :through => :event_attendees

  has_many :checkouts_to, :dependent => :destroy, :class_name => "Checkout", :foreign_key => :user_id
  has_many :checkouts_by, :class_name => "Checkout", :foreign_key => :opener_id
  has_many :checkout_events, :dependent => :destroy

  #FIXME Right now we symlink to the /data/upload directory in production
  #circumventing the security restrictions enabled in that directory.  We
  #really should serve out of that directory instead using the
  #upload.snstheatre.org domain.  This link details one way to do that.
  #http://stackoverflow.com/questions/2562249/how-can-i-set-paperclips-storage-mechanism-based-on-the-current-rails-environmen
  has_attached_file :headshot, 
    :styles => {:medium => "150x150#", :thumb => "50x50#"},
    :default_url => '/images/missing/:class_:style.png'

  validates_attachment_size :headshot, :less_than => 10.megabytes,
    :message => "must be less than 10 megabytes",
    :unless => lambda { |user| !user.headshot.nil? }
  validates_attachment_content_type :headshot,
    :content_type => ["image/jpeg", "image/gif", "image/png", "image/bmp"],
    :message => "must be an image",
    :unless => lambda { |user| !user.headshot.nil? }	

  validates_presence_of :first_name, :last_name, :encrypted_password, :password_salt

  # FIXME we should lowercase the email provided by the user 
  # FIXME we should use Devise's built-in email validation
  validates_length_of :phone, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_length_of :residence, :minimum => 3, :allow_nil => true, :allow_blank => true

  validates_length_of :smc, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_numericality_of :smc, :only_integer => true, :allow_nil => true, :allow_blank => true
  validates_length_of :graduation_year, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_numericality_of :graduation_year, :only_integer => true, :allow_nil => true, :allow_blank => true
  
  before_validation :set_random_password

  acts_as_phone_number :phone

  DEFAULT_PERMISSIONS = %w(createGroup)
  HOME_COLLEGES = %w(SCS H&SS CIT CFA MCS TSB SHS BXA)

  scope :recent, where(["current_sign_in_at > ?", 2.weeks.ago]).order("current_sign_in_at DESC")

####################
# OBJECT OVERRIDES #
####################

  def to_s 
    name
  end
  
  def to_param
    andrew_id
  end
  
  def <=>(other)
    (last_name + first_name)<=>(other.last_name + other.first_name)
  end
  
###################
# TABLE OVERRIDES #
###################

  def andrew_id=(a)
    unless @andrew_id.nil?
      logger.debug "Someone tried to set #{self.name}'s andrew id, but it's not nil so we're going to warn and ignore that"
      return
    end
    super
    self.email="#{andrew_id}@andrew.cmu.edu"
    self.andrew_id
  end
  
  def email=(e)
    super
    if self.andrew_id.nil? and e.include? "@andrew.cmu.edu"
      self.andrew_id = e[0...e.index("@andrew.cmu.edu")]
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
  
  def incomplete_record?
    #TODO
    true
  end
  
  def age
    ((Time.now - DateTime.parse(birthday.to_s))/(60*60*24)/365.2422).to_i
  end

  def name
    first_name + " " + last_name
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

#################
# EVENT METHODS #
#################

  # All events which should appear on the user's calendar
  def user_events
    es = events.all
    groups.each do |g|
      es += g.events.select { |e| e.event_attendees.count == 0 }
    end
    return es
  end

  def future_events
    user_events.select{|e| e.future?}
  end

####################
# CHECKOUT METHODS #
####################
  def can_check_out_items_to?(other, group)
    unless other.class.to_s == "User"
      #puts "other is not a User"
      return false
    end
    unless ['Group','Show','Board'].include? group.class.to_s
      #puts "group is not a Group, Show or Board"
      return false
    end
    
    cs = Permission.fetch "checkoutSelf"
    co = Permission.fetch "checkoutOther"
    
    # if user has checkoutSelf globally, he can check out items to himself in any of his groups
    return true if has_global_permission? cs and groups.include? group and self == other
    
    # if user has checkoutSelf for a group, he can check out items to himself in that group
    return true if group.permissions_for(self).include? cs and self == other
    
    # if user has checkoutOther globally, she can check out items to anyone in any group
    return true if has_global_permission? co and other.groups.include? group
    
    # if user has checkoutOther for a group, she can check out items to anyone in that group
    return true if group.permission_for(self).include? co and other.groups.include? group
    
    return false
  end

  def allowedToCauseEvent? (event,checkout)
    return false unless event.class.to_s == 'Array' and checkout.class.to_s == 'Checkout'
    eventType = event[0]
    eventList = event[5]
    
    return true if eventList.include? 'other' # anyone is allowed to do an 'other' event
    return true if eventList.include? 'opener' and self == checkout.opener
    return true if eventList.include? 'owner' and self == checkout.user
    return false
  end
  
  def current_checkouts_to
    checkouts_to.select{|ch| ch.open?}
  end
  
  def current_checkouts_by
    checkouts_by.select{|ch| ch.open?}
  end

private

  # FIXME: this doesn't seem to work
  # use @password
  def set_random_password
    if password.nil? then
      password = ActiveSupport::SecureRandom.hex(16)
    end
  end
end
