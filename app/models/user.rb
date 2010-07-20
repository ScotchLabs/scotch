class User < ActiveRecord::Base
  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence, :birthday, :birthmonth, :birthyear

  has_many :positions
  has_many :groups, :through => :positions

  has_many :event_attendees, :dependent => :destroy

  has_many :checkouts, :dependent => :destroy
  has_many :checkout_events, :dependent => :destroy

  validates_presence_of :email, :first_name, :last_name
  validates_uniqueness_of :email
  validates_length_of :phone, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_length_of :residence, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_length_of :smc, :minimum => 3, :allow_nil => true, :allow_blank => true
  validates_length_of :graduation_year, :minimum => 3, :allow_nil => true, :allow_blank => true
  
  before_validation :set_random_password

  acts_as_phone_number :phone

  DEFAULT_PERMISSIONS = %w(createGroup)
  HOME_COLLEGES = %w(SCS H&SS CIT CFA MCS TSB SHS BXA)

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
  
  def birthdate
    return nil unless birthmonth and birthday and birthyear
    DateTime.parse("#{birthmonth}/#{birthday}/#{birthyear}")
  end
  
  def age
    ((Time.now - DateTime.parse(birthdate.to_s))/(60*60*24)/365.2422).to_i
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

  private

  def set_random_password
    if password.nil? then
      password = ActiveSupport::SecureRandom.hex(16)
    end
  end
end
