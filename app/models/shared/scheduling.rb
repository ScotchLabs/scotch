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
  end
  
  def all_events
    self.events + self.attended_events
  end
  
  def events_in_range(start_time, end_time)
    self.events.where('(start_time > ? AND start_time < ?) OR (end_time > ? AND end_time < ?)', start_time, end_time, start_time, end_time) + 
    self.attended_events.where('(start_time > ? AND start_time < ?) OR (end_time > ? AND end_time < ?)', start_time, end_time, start_time, end_time)
  end
  
  def has_conflicts?(start_time = nil, *end_time)
    if start_time
      if self.events_in_range(start_time, end_time).count > 0
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
  
  def get_conflicts(start_time, end_time, attendees = false)
    if attendees
      result = attendees.map do |a|
        a.get_conflicts(start_time, end_time)
      end
    else
      result = self.events_in_range(start_time, end_time)
    end
    
    result.empty? ? nil : result
  end
end