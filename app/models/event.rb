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
#  session                :string(255)
#  all_day                :boolean(1)
#  privacy_type           :string(255)
#  attendee_limit         :integer(4)
#  type                   :string(255)

class Event < ActiveRecord::Base
  has_many :event_attendees, :dependent => :destroy
  has_many :users, :through => :event_attendees, :source => :owner, :source_type => 'User'
  has_many :groups, :through => :event_attendees, :source => :owner, :source_type => 'Group'
  
  belongs_to :owner, :polymorphic => true

  scope :auditions, where(event_type: 'audition')
  
  PERIODS = [
    ['Minutes','minutes'],
    ['Hours','hours'],
    ['Days','days'],
    ['Weeks','weeks'],
    ['Months','months'],
    ['Years','years']
  ]
  
  COLORS = {
    'user' => {:main_background => '#000000', :time_background => '#0C0C0C', :time_border => '#101010'},
    'rehearsal' => {:main_background => '#FF4540', :time_background => '#FF0700', :time_border => '#BF3330'},
    'meeting' => {:main_background => '#36DF64', :time_background => '#00BF32', :time_border => '#248F40'},
    'build' => {:main_background => '#4284D3', :time_background => '#0E53A7', :time_border => '#274E7D'},
    'audition' => {:main_background => '#FF9640', :time_background => '#FF7400', :time_border => '#BF7130'},
    'show' => {:main_background => '#9440D5', :time_background => '#660BAB', :time_border => '#592680'},
    'social' => {:main_background => '#FF1300', :time_background => '#008500', :time_border => '#03899C'}
  }
  
  validate :times_are_sane # rails3?
  validate :audition_has_one_attendee
  validates_presence_of :title, :start_time, :end_time
  validates_numericality_of :attendee_limit, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :session, :in => ['none', 'mini', 'semester'], :default => 'none'
  validates_inclusion_of :event_type, :in => COLORS.keys
  after_save :save_attendees
  
  default_scope order('start_time ASC')
  
  attr_accessor :temp_attendees
  
  
  def self.periods
    PERIODS.clone
  end
  
  def self.sessions(today = DateTime.now)
        
    if today.month > 6
      result = {mini:[DateTime.new(today.year, 8, 27)..DateTime.new(today.year, 10, 19), DateTime.new(today.year, 10, 22)..DateTime.new(today.year, 12, 20),
        DateTime.new(today.year + 1, 1, 14)..DateTime.new(today.year + 1, 3, 11), DateTime.new(today.year + 1, 3, 18)..DateTime.new(today.year + 1, 5, 16)],
        semester: [DateTime.new(today.year, 8, 27)..DateTime.new(today.year, 12, 20), DateTime.new(today.year + 1, 1, 14)..DateTime.new(today.year + 1, 5, 16)]}
    else
      result = {mini:[DateTime.new(today.year + 1, 1, 14)..DateTime.new(today.year, 3, 11), DateTime.new(today.year + 1, 3, 18)..DateTime.new(today.year, 5, 16),
        DateTime.new(today.year, 8, 27)..DateTime.new(today.year, 10, 19), DateTime.new(today.year, 10, 22)..DateTime.new(today.year, 12, 20)],
        semester: [DateTime.new(today.year, 1, 14)..DateTime.new(today.year, 5, 16), DateTime.new(today.year, 8, 27)..DateTime.new(today.year, 12, 20)]}
    end
    
    result
  end

  scope :future, where("end_time > NOW()")
  
  def parent
    self.owner.type == 'User' ? nil : self.owner
  end
  
  def all_attendees
    self.users + self.groups
  end
  
  def attendees=(ids)
    self.temp_attendees = ids
  end
  
  def attendees
    self.event_attendees.map do |a|
      a.owner.id.to_s + ':' + a.owner.class.model_name
    end
  end
  
  def has_conflicts?
    self.all_attendees.each do |a|
      if a.has_conflicts?(self.start_time, self.end_time, self.id)
        return true
      end
    end
    
    return false
  end
  
  def get_conflicts
    conflicts = self.all_attendees.map do |a|
      a.get_conflicts(self.start_time, self.end_time, self.id)
    end
    
    conflicts.compact
  end
  
  def freebusys
    self.all_attendees.map do |a|
      {id: a.id, type: a.class.model_name, freebusys: a.freebusys}
    end
  end
  
  def get_conflictors
    conflicts = self.all_attendees.map do |a|
      if a.has_conflicts?(self.start_time, self.end_time, self.id)
        a.name
      end
    end
    
    conflicts.compact
  end
  
  def period=(session_id)
    sesh = false
    self.session_name = session_id
    case session_id
    when 'semester 1'
      sesh = Event.sessions(self.start_time)[:semester][0]
      self.session = 'semester'
    when 'semester 2'
      sesh = Event.sessions(self.start_time)[:semester][1]
      self.session = 'semester'
    when 'mini 1'
      sesh = Event.sessions(self.start_time)[:mini][0]
      self.session = 'mini'
    when 'mini 2'
      sesh = Event.sessions(self.start_time)[:mini][1]
      self.session = 'mini'
    when 'mini 3'
      sesh = Event.sessions(self.start_time)[:mini][2]
      self.session = 'mini'
    when 'mini 4'
      sesh = Event.sessions(self.start_time)[:mini][3]
      self.session = 'mini'
    else
      self.session = 'none'
      return
    end
    
    weekday = self.start_time.wday
    delta = self.end_time.to_i - self.start_time.to_i
    
    new_start = sesh.first
    while new_start.wday != weekday
      new_start = new_start.advance(days: 1)
    end
    
    self.start_time = self.start_time.change(year: new_start.year, month: new_start.month, day: new_start.day)
    self.end_time = self.start_time.advance(seconds: delta)
  end
  
  def period
    if !self.session.nil? && self.session != 'none'
      Event.sessions(self.start_time)[self.session.to_sym].each do |s|
        if s.cover? self.start_time
          return s
        end
      end
    else
      false
    end
  end
  
  def mini
    Event.sessions(self.start_time)[:mini].each do |s|
      if s.cover? self.start_time
        return s
      end
    end
    
    false
  end
  
  def semester
    Event.sessions(self.start_time)[:semester].each do |s|
      if s.cover? self.start_time
        return s
      end
    end
    
    false
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
  
  def as_json(options = {})
    {id: self.id, title: self.title, start: self.start_time, end: self.end_time, location: self.location, body: self.description, 
      event_type: self.event_type, period: self.period, session_name: self.session_name, attendees: self.attendees}.merge COLORS[self.event_type]
  end
protected

  def times_are_sane
    errors[:start_time] << "cannot be in the past" if start_time && start_time.past? && self.session == 'none'
    errors[:end_time] << "cannot be before start time" if end_time && end_time < start_time && self.session == 'none'
  end
  
  def save_attendees
    if !temp_attendees.nil? && temp_attendees.kind_of?(Array)
      old_attendees = self.event_attendees
      self.event_attendees.clear
      temp_attendees.uniq.each do |a|
        split_id = a.split(':')
        self.event_attendees.create(:owner_id => split_id[0], :owner_type => split_id[1])
      end
    elsif temp_attendees.kind_of?(User)
      self.event_attendees.clear
      self.event_attendees.create(:owner_id => temp_attendees.id, :owner_type => 'User')
    end
  end

  def audition_has_one_attendee
    if self.event_type == 'audition'
      self.event_attendees.count <= 1
    else
      true
    end
  end

end
