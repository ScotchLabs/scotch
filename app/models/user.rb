class User < ActiveRecord::Base
  # Use User for authentication
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :phone, :home_college, :graduation_year, :smc,
    :gender, :residence

  has_many :positions
  has_many :groups, :through => :positions

  has_many :event_attendees

  has_many :checkouts
  has_many :checkout_events
end
