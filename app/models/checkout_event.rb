include ApplicationHelper

class CheckoutEvent < ActiveRecord::Base
  belongs_to :checkout
  belongs_to :user
  
  # User reference:
  # "causer" => user of this event
  # "opener" => user of the 'opened' event of this event's checkout
  # "user" => user of this event's checkout
  
  # format of event:
  #   [EVENT KEY, human-readable future tense, human-readable past tense, many allowed?, causer needs permission?, causer needs to be opener?]
  # if causer does not need to be the opener, causer can only be the use
  EVENT_TYPES = [
    # No notes.
    ['opened', 'Check Out', 'checked out', false, true, true],
    # Note is text.
    ['closed', 'Check In', 'checked in', false, false, true],
    # Note is a float with up to 2 decimals.
    ['paymentReceived', 'Pay For', 'paid for', true, false, true],
    # Latest paymentRequired is the current payment required.
    # Note is a float with up to 2 decimals.
    ['paymentRequired', 'Charge User', 'updated payment required for', true, false, true],
    # Latest deadlined is the current deadline.
    # Note is a string parsable as a date.
    ['deadlined', 'Set Check-In Deadline', 'updated deadline for', true, false, true],
    # MANY noteds are allowed. Note is text.
    ['noted', 'Make a Note', 'made a note concerning', true, false, false]
  ]
  
  validates_presence_of :checkout_id, :user_id
  validates_associated :checkout, :user
  validates_inclusion_of :event, :in => EVENT_TYPES.map{|e| e[0]}
  validate :event_type
  validate :notes_ok
  validate :user_has_permission
  
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
    errors[:event] << "Checkout already has a '#{CheckoutEvent.event_name('opened')}' event" if event == 'opened' and checkout.has_event?('opened')
    errors[:event] << "Checkout already has a '#{CheckoutEvent.event_name('closed')}' event" if event == 'closed' and checkout.has_event?('closed')
    errors[:event] << "Not allowed to close Checkout: outstanding balance" if event == 'closed' and checkout.paymentReceived < checkout.paymentRequired
    #TODO ASK why else wouldn't we be able to close a checkout?
  end
  
  def notes_ok
    case event
    when 'opened'
      errors[:event] << "No note allowed for an 'opened' event." unless notes.nil? or notes.blank?
    when 'closed'
      # note allowed as text, no validation required
    when 'paymentReceived'
      errors[:event] << "Note may not be blank" if notes.nil? or notes.blank?
      errors[:event] << "Note must consist of a dollar amount with up to 2 decimals." unless notes =~ /\d*(\.\d?\d?)?/
    when 'paymentRequired'
      errors[:event] << "Note may not be blank" if notes.nil? or notes.blank?
      errors[:event] << "Note must consist of a dollar amount with up to 2 decimals." unless notes =~ /\d*(\.\d?\d?)?/
    when 'deadlined'
      errors[:event] << "Note may not be blank" if notes.nil? or notes.blank?
      begin
        DateTime.parse(notes)
      rescue ArgumentError => e
        errors[:event] << "Note failed to parse. Make sure it's a human-readable date and/or time. ArgumentError: #{e.message}"
      end
    when 'noted'
      errors[:event] << "Note may not be blank" if notes.nil? or notes.blank?
    else
      errors[:event] << "does not appear to be valid. Can't validate note."
    end
  end
  
  def user_has_permission
    #TODO depending on what event type this has, check if the user has permission to post the event
  end
end
