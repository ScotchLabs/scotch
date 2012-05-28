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
  
  def has_conflicts?(start_time = nil, *end_time)
    if start_time
      self.all_events.each do |e|
        if (start_time < e.start_time && e.start_time < end_time[0]) || (start_time < e.end_time && e.end_time < end_time[0])
          return true
        end
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
end