# == Schema Information
#
# Table name: events
#
#  id                     :integer(4)      not null, primary key
#  title                  :string(255)
#  group_id               :integer(4)
#  start_time             :datetime
#  end_time               :datetime
#  location               :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  description            :text
#  repeat_id              :integer(4)
#  repeat_frequency       :integer(4)
#  repeat_period          :string(255)
#  all_day                :boolean(1)
#  privacy_type           :string(255)
#  attendee_limit         :integer(4)
#  stop_after_occurrences :integer(4)
#  stop_on_date           :string(255)
#

class Event < ActiveRecord::Base
  has_many :event_attendees, :dependent => :destroy
  has_many :users, :through => :event_attendees, :source => :owner, :source_type => 'User'
  has_many :groups, :through => :event_attendees, :source => :owner, :source_type => 'Group'
  
  belongs_to :owner, :polymorphic => true
  
  PERIODS = [
    ['Minutes','minutes'],
    ['Hours','hours'],
    ['Days','days'],
    ['Weeks','weeks'],
    ['Months','months'],
    ['Years','years']
  ]
  
  validate :times_are_sane # rails3?
  validates_presence_of :title, :start_time, :end_time
  validates_numericality_of :attendee_limit, :allow_nil => true, :allow_blank => true
  validate :attendee_limit_is_sane
  validates_inclusion_of :all_day, :in => [true, false], :message => "must be either true or false"
  validate :repeat_id_is_sane
  validates_inclusion_of :privacy_type, :in => ['open','limited','closed'], :allow_nil => true
  
  
  def self.periods
    PERIODS.clone
  end

  scope :future, where("end_time > NOW()")
  
  def attendees
    self.users + self.groups
  end
  
  def has_conflicts?
    self.attendees.each do |a|
      if a.has_conflicts?(self.start_time,self.end_time)
        return true
      end
    end
    
    return false
  end
  
  def get_conflicts
    conflicts = self.attendees.map do |a|
      a.get_conflicts(self.start_time, self.end_time)
    end
    
    conflicts.compact
  end

  def repeat_children
    Event.where(:repeat_id => id)
  end
  def repeat_parent
    Event.where(:id => repeat_id).first
  end
  def propagate(old_event)
    c=repeat_children
    c.each do |child|
      child.title = title
      child.location = location
      child.description = description
      child.all_day = all_day
      child.privacy_type = privacy_type
      child.attendee_limit = attendee_limit
      child.start_time = child.start_time.advance(:seconds => start_time.to_i-old_event.start_time.to_i)
      child.end_time = child.end_time.advance(:seconds => end_time.to_i-old_event.end_time.to_i)
      child.attendees = attendees
      child.save
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

  def attendee_limit_is_sane
    errors[:attendee_limit] << "must be an integer" if privacy_type == "limited" and not attendee_limit
  end

  def times_are_sane
    errors[:start_time] << "cannot be in the past" if start_time and start_time.past?
    errors[:end_time] << "cannot be before start time" if end_time and end_time < start_time
  end
  
  def repeat_id_is_sane
    errors[:repeat_id] << "points to an invalid Event" if repeat_id and !Event.find(repeat_id)
  end

end
