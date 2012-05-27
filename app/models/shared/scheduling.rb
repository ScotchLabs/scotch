module Shared::Scheduling
  
  def self.included(base)
    base.extend(ClassMethods).relate
  end
  
  module ClassMethods
    def relate
      has_many :events, :class_name => 'Event', :as => :owner, :dependent => :destroy
      has_many :event_attendees, :as => :owner, :dependent => :destroy
      has_many :attended_events, :class_name => 'Event', :through => :event_attendees
    end
  end
  
  def all_events
    self.owned_events + self.attended_events
  end
  
  def has_conflicts?(start_time = false, end_time = false)
    if start_time
      self.all_events.each do |e|
        if start_time < e.start_time < start_time || end_time < e.end_time < end_time
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