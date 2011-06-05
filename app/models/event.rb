class Event < ActiveRecord::Base
  has_many :event_attendees, :dependent => :destroy
  has_many :attendees, :through => :event_attendees, :source => :user
  
  belongs_to :group

  attr_protected :group_id
  
  PERIODS = [
    ['Minutes','minutes'],
    ['Hours','hours'],
    ['Days','days'],
    ['Weeks','weeks'],
    ['Months','months'],
    ['Years','years']
  ]
  
  validate :times_are_sane # rails3?
  validates_presence_of :group, :title, :start_time, :end_time
  validates_numericality_of :repeat_frequency, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :repeat_period, :in => PERIODS.map{|p| p[1]}, :allow_nil => true, :allow_blank => true
  validates_numericality_of :stop_after_occurrences, :allow_nil => true, :allow_blank => true
  validates_numericality_of :attendee_limit, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :all_day, :in => [true, false], :message => "must be either true or false"
  validate :repeat_id_is_sane
  validates_inclusion_of :privacy_type, :in => ['open','limited','closed'], :allow_nil => true
  
  
  def self.periods
    PERIODS.clone
  end

  scope :future, where("end_time > NOW()")

  def repeat_children
    Event.where(:repeat_id => id)
  end
  def repeat_parent
    Event.where(:id => repeat_id).first
  end
  def propagate
    # propagates all changes (including repeat fields) to repeat_children
    c=repeat_children
    i=0
    if stop_on_date
      t=end_time
      g=stop_on_date
      n=0
      while t < g
        n=n+1
        t=t.advance(repeat_period.to_sym => repeat_frequency)
      end
    else
      n = stop_after_occurrences
    end
    
    st=start_time
    en=end_time
    n.times do
      st=st.advance(repeat_period.to_sym => repeat_frequency)
      en=en.advance(repeat_period.to_sym => repeat_frequency)
      if c[i].start_time == st
        c[i].update_attributes({
          :title => title, 
          :start_time => st, 
          :end_time => en, 
          :location => location, 
          :description => description, 
          :repeat_frequency => repeat_frequency, 
          :repeat_period => repeat_period, 
          :all_day => all_day, 
          :privacy_type => privacy_type, 
          :attendee_limit => attendee_limit, 
          :stop_after_occurrences => stop_after_occurences ? stop_after_occurrences-1 : nil,
          :stop_on_date => stop_on_date})
        i=i+1
      else
        e=this.clone
        e.repeat_id = id
        e.start_time = st
        e.end_time = en
        e.save!
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
    errors[:stop_on_date] << "cannot be before end time" if stop_on_date and stop_on_date < end_time
  end
  
  def repeat_id_is_sane
    errors[:repeat_id] << "points to an invalid Event" if repeat_id and !Event.find(repeat_id)
  end

end
