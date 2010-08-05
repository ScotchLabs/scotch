class User < ActiveRecord::Base
  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence, :birthday

  has_many :positions
  has_many :groups, :through => :positions

  has_many :event_attendees, :dependent => :destroy
  has_many :events, :through => :event_attendees

  has_many :checkouts, :dependent => :destroy
  has_many :checkout_events, :dependent => :destroy

  validates_presence_of :first_name, :last_name

  # FIXME we should lowercase the email provided by the user 
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
      es += g.events.select { |e| e.attendees.count == 0 }
    end
    return es
  end

  # FIXME redo this as a scope
  def active_groups
    self.groups.all.select{|g| g.active?}
  end

  private

  # FIXME: this doesn't seem to work
  def set_random_password
    if password.nil? then
      password = ActiveSupport::SecureRandom.hex(16)
    end
  end
end
