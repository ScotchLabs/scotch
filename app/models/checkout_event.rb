include ApplicationHelper

class CheckoutEvent < ActiveRecord::Base
  belongs_to :checkout
  belongs_to :user
  
  # User reference:
  # "causer" => user of this event
  # "opener" => user of the 'opened' event of this event's checkout
  # "owner" => user of this event's checkout
  
  # format of event:
  #   EVENT KEY,
  #   human-readable future tense,
  #   human-readable past tense,
  #   many allowed?,
  #   causer needs permission?,
  #   list of allowed users
  #   Note display-text,
  # if causer does not need to be the opener, causer can only be the user (unless the event is 'opened' or 'noted')
  EVENT_TYPES = [
    # No notes.
    ['opened', 'Check Out', 'checked out', false, true, ['opener'], nil],
    # Note is text.
    ['closed', 'Check In', 'checked in', false, false, ['opener','owner'], "Note"],
    # Note is a float with up to 2 decimals.
    ['paymentReceived', 'Pay For', 'paid', true, false, ['opener','owner'], "Amount Paid"],
    # Latest paymentRequired is the current payment required.
    # Note is a float with up to 2 decimals.
    ['paymentRequired', 'Charge User', 'updated the payment required', true, false, ['opener','owner'], "Amount Charged"],
    # Latest deadlined is the current deadline.
    # Note is a string parsable as a date.
    ['deadlined', 'Set Check-In Deadline', 'updated the deadline', true, false, ['opener','owner'], "Date Due"],
    # Note is text.
    ['noted', 'Make a Note', 'made a note', true, false, ['opener','owner','other'], "Note"]
  ]
  
  validates_presence_of :checkout, :user
  validates_inclusion_of :event, :in => EVENT_TYPES.map{|e| e[0]}
  validate :event_type
  validate :notes_ok
  validate :user_has_permission
  validate :checkout_openable
  
  attr_protected :user_id
  
  # returns the human-readable string associated with the
  # given EVENT_TYPE key
  def self.event_name(arg=nil)
    return nil if arg.nil?
    e=CheckoutEvent.event(arg)
    return nil if e.nil?
    e[1]
  end
  
  def self.events
    EVENT_TYPES.clone
  end
  
  def self.event(arg=nil)
    return nil if arg.nil?
    for event in EVENT_TYPES
      return event.clone if event[0] == arg
    end
    nil
  end
  
  def to_s
    "#{user} #{CheckoutEvent.event(event)[2]} #{checkout.item} on #{format_time(created_at)}"
  end
  
  def name
    CheckoutEvent.event_name(event)
  end

protected

  def event_type
    errors[:checkout] << "has an outstanding balance and may not be closed." if event == 'closed' and checkout.paymentReceived < checkout.paymentRequired
    #TODO ASK why else wouldn't we be able to close a checkout?
  end
  
  def notes_ok
    noteDisplayText = (CheckoutEvent.event('noted')[6] or :event)
    case event
    when 'opened'
      errors[noteDisplayText] << "no note allowed" unless notes.nil? or notes.blank?
    when 'closed'
      # note allowed as text, no validation required
    when 'paymentReceived'
      errors[noteDisplayText] << "may not be blank" if notes.nil? or notes.blank?
      errors[noteDisplayText] << "must consist of a dollar amount with up to 2 decimals." unless notes =~ /^\d*(\.\d?\d?)?$/
    when 'paymentRequired'
      errors[noteDisplayText] << "may not be blank" if notes.nil? or notes.blank?
      errors[noteDisplayText] << "must consist of a dollar amount with up to 2 decimals." unless notes =~ /^\d*(\.\d?\d?)?$/
    when 'deadlined'
      errors[noteDisplayText] << "may not be blank" if notes.nil? or notes.blank?
      begin
        DateTime.parse(notes)
      rescue ArgumentError => e
        errors[noteDisplayText] << "failed to parse. Make sure it's a human-readable date and/or time. ArgumentError: #{e.message}"
      end
    when 'noted'
      errors[noteDisplayText] << "may not be blank" if notes.nil? or notes.blank?
    else
      errors[:event] << "does not appear to be valid. Can't validate note."
    end
  end
  
  def user_has_permission
    v = CheckoutEvent.event(event)
    #TODO depending on what event type this has, check if the user has permission to post the event
    # check if multiple of these events are allowed
    errors[:event] << "cannot exist more than once for this checkout." if checkout.has_event? v[0] and !v[3]
    
    # check if causer needs to be the opener
    # otherwise check if current_user is checkout user
    errors[:user] << "must be on the list: #{v[5].join(", ")}" unless user.allowedToCauseEvent?(v, checkout)
    
    # check if causer needs/has permission
    #puts "does the event require the user to have permission? #{v[4]}"
    #puts "does the user have permission? #{user.can_check_out_items_to? checkout.user, checkout.group}"
    #puts "well, the user is #{checkout.user} and the group is #{checkout.group}"
    errors[:user] << "does not have permission to create event." if v[4] and !user.can_check_out_items_to?(checkout.user, checkout.group)
  end
  
  def checkout_openable
    errors[:checkout] << "is closed and may not be opened." unless checkout.openable?
  end
end
