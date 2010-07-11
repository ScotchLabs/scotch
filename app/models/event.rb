class Event < ActiveRecord::Base
  belongs_to :group
  has_many :event_attendees
  # FIXME: is there a proper rails 3 way to do this?
  has_many :attendees, :conditions => "event_attendees.user_id IS NOT NULL", :class_name => "EventAttendee"

  attr_protected :group_id

  #TODO: validate that start_time and end_time are sane
  #TODO: validate on creation that event is in the future
  validates_presence_of :group, :title, :start_time, :end_time

  def self.create_audition(group,count,length,signups,params)
    time = nil
    es = []
    count.times do
      e = self.new(params)
      e.group = group

      if (time == nil)
        time = e.start_time
      else
        e.start_time = time
      end
      time += length.minutes
      e.end_time = time

      e.save!

      signups.times do
        e.event_attendees.create
      end
    end
  end

  def future?
    start_time.future?
  end
  def ongoing?
    start_time.past? && end_time.future?
  end
  def past?
    end_time.past?
  end
  def to_s
    title
  end
  def <=>(other)
    start_time <=> other.start_time
  end
end
