class Event < ActiveRecord::Base
  has_many :event_attendees, :dependent => :destroy
  has_many :attendees, :through => :event_attendees, :source => :user
  
  belongs_to :group

  attr_protected :group_id
  
  PERIODS = [
    ['Minutes','m'],
    ['Hours','h'],
    ['Days','d'],
    ['Weeks','w'],
    ['Months','M'],
    ['Years','y']
  ]
  
  validate :times_are_sane # rails3?
  validates_presence_of :group, :title, :start_time, :end_time
  validates_numericality_of :repeat_frequency, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :repeat_period, :in => PERIODS.map{|p| p[1]}, :allow_nil => true, :allow_blank => true
  validate :repeat_id_is_sane
  validates_inclusion_of :privacy_type, :in => ['open','limited','closed'], :allow_nil => true
  
  
  def self.periods
    PERIODS.clone
  end

  scope :future, where("end_time > NOW()")

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
  def to_ical_event
    ievent = Icalendar::Event.new
    ievent.start = start_time.to_datetime
    ievent.end = end_time.to_datetime
    ievent.dtstamp = created_at.to_datetime
    ievent.summary = title
    ievent.description = (description or "")
    ievent.uid = "event-#{id}"
    return ievent
  end
  def <=>(other)
    start_time <=> other.start_time
  end
  def className
    group.className
  end
protected

  def times_are_sane
    errors[:start_time] << "cannot be in the past" if start_time.past?
    errors[:end_time] << "cannot be before start time" if end_time and end_time < start_time
  end
  
  def repeat_id_is_sane
    errors[:repeat_id] << "points to an invalid Event" if repeat_id and !Event.find(repeat_id)
  end

end
