class Event < ActiveRecord::Base
  belongs_to :group
  has_many :event_attendees, :dependent => :destroy
  # FIXME: is there a proper rails 3 way to do this?
  # EDIT-sewillia: do you mean this? I think it's old rails
  has_many :attendees, :through => :event_attendees, :source => :user
  # has_many :attendees, :conditions => "event_attendees.user_id IS NOT NULL", :class_name => "EventAttendee"

  attr_protected :group_id

  #TODO: validate that start_time and end_time are sane
  #TODO: validate on creation that event is in the future
  validate :times_are_sane # rails3?
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
  
protected

  def times_are_sane
    errors[:start_time] << "cannot be in the past" if start_time.past?
    errors[:end_time] << "cannot be before start time" if end_time <= start_time
  end

end
