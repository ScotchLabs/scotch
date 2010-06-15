class Event < ActiveRecord::Base
  belongs_to :group
  has_many :event_attendees

  attr_protected :group_id

  validates_presence_of :group_id

  def to_s
    title
  end
end
