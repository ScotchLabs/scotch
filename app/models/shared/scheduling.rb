module Shared::Scheduling
  
  def self.included(base)
    base.extend(ClassMethods).relate
  end
  
  module ClassMethods
    def relate
      has_many :events, :class_name => 'Event', :as => :owner, :dependent => :destroy
      has_many :event_attendees, :as => :owner, :dependent => :destroy
      has_many :attended_events, :through => :event_attendees, :source => :event
    end
    
    def freebusys(members)
      members.map do |a|
        {id: a.id, type: a.class.model_name, freebusys: a.freebusys}
      end
    end
  end
  
  def all_events
    self.events + self.attended_events
  end
  
  def events_in_range(start_time, end_time, event_id)
    self.events.where('((start_time BETWEEN ? AND ?) OR (end_time BETWEEN ? AND ?)) AND events.id != ?', start_time, end_time, 
    start_time, end_time, event_id) + 
    self.attended_events.where('((start_time BETWEEN ? AND ?) OR (end_time BETWEEN ? AND ?)) AND events.id != ?', start_time, 
    end_time, start_time, end_time, event_id)
  end
  
  def has_conflicts?(start_time = nil, end_time = nil, *event_id)
    if start_time
      if self.events_in_range(start_time, end_time, event_id).count > 0
        return true
      end
    else
      self.all_events.each do |e|
        if e.has_conflicts?
          return true
        end
      end
    end
    
    return false
  end
  
  def get_conflicts(start_time, end_time, event_id, attendees = false)
    if attendees
      result = attendees.map do |a|
        a.get_conflicts(start_time, end_time, event_id)
      end
    else
      result = self.events_in_range(start_time, end_time, event_id)
    end
    
    result.empty? ? [] : result.compact
  end
  
  def freebusys(is_user = false, start_time = false, *end_time)
    if is_user
      conflicts = self.get_conflicts(start_time, end_time, 0)
    
      conflicts.map do |c|
        {start: c.start_time, end: c.end_time, free: false}
      end
    else
      year = self.school_year
      self.members.map do |m|
        {id: m.id, type: m.class.model_name, freebusys: m.freebusys(true, year.first, year.last)}
      end
    end
  end
end