class User < ActiveRecord::Base
  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence, :birthday, :headshot

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
  has_attached_file :headshot, :styles => { :medium => "200x200>", :thumb => "75x75>" }, 
    :default_url => '/images/missing_headshot.jpg'

  validates_presence_of :first_name, :last_name, :encrypted_password, :password_salt

  # FIXME we should lowercase the email provided by the user 
  # FIXME we should use Devise's built-in email validation
  validates_format_of :email, :with => /\A([a-z0-9+]+)@andrew\.cmu\.edu\Z/i

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

  def self.recent
    User.where(["current_sign_in_at > ?", 2.hour.ago]).all
  end

  def to_s 
    name
  end
  
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
  
  def future_events
    user_events.select{|e| e.future?}
  end
  
  def age
    ((Time.now - DateTime.parse(birthday.to_s))/(60*60*24)/365.2422).to_i
  end

  def name
    first_name + " " + last_name
  end

  def global_permissions
    Group.system_group.permissions_for(self) +
      DEFAULT_PERMISSIONS.collect {|p| Permission.fetch(p)}
  end

  def has_global_permission?(permission)
    global_permissions.include?(permission) ||
      global_permissions.include?(Permission.fetch("superuser"))
  end

  def <=>(other)
    (last_name + first_name)<=>(other.last_name + other.first_name)
  end

  # All events which should appear on the user's calendar
  def user_events
    es = events.all
    groups.each do |g|
      es += g.events.select { |e| e.event_attendees.count == 0 }
    end
    return es
  end

  # FIXME redo this as a scope
  #sewillia: I don't think we should. scopes are called on the class to return instances,
  #  not called on instances to return associations
  def active_groups
    self.groups.all.select{|g| g.active?}
  end
  def active_positions
    positions.select{ |p| p.group.active? }
  end
  
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
    
    if has_global_permission? cs and groups.include? group and self == other
      # if user has checkoutSelf globally, he can check out items to
      # himself in any of his groups
      #puts "user has checkoutSelf globally"
      #puts "user's groups includes group, other is user"
      return true
      
    elsif group.permissions_for(self).include? cs and self == other
      # if user has checkoutSelf for a group, he can check out items to
      # himself in that group
      #puts "user has checkoutSelf for group"
      #puts "other is user"
      return true
      
    elsif has_global_permission? co and other.groups.include? group
      # if user has checkoutOther globally, she can check out items to
      # anyone in any group
      #puts "user has checkoutOther globally"
      #puts "other's groups includes group"
      return true
      
    elsif group.permission_for(self).include? co and other.groups.include? group
      # if user has checkoutOther for a group, she can check out items to
      # anyone in that group
      #puts "user has checkoutOther for group"
      #puts "other is in group"
      return true
      
    else
      #puts "user does not have permissions, or other/group combo was incorrect"
      false
    end
    false
  end

  def allowedToCauseEvent? (event,checkout)
    #puts "checking if #{name} is allowed to cause a #{event[0]} on #{checkout}"
    return false unless event.class.to_s == 'Array' and checkout.class.to_s == 'Checkout'
    eventType = event[0]
    eventList = event[5]
    #puts "event list: #{eventList.join(", ")}"
    #puts "checking for other..."
    return true if eventList.include? 'other' # anyone is allowed to do an 'other' event
    #puts "checking for opener..."
    return true if eventList.include? 'opener' and self == checkout.opener
    #puts "checking for owner..."
    return true if eventList.include? 'owner' and self == checkout.user
    #puts "none found"
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
  def set_random_password
    if password.nil? then
      password = ActiveSupport::SecureRandom.hex(16)
    end
  end
end
