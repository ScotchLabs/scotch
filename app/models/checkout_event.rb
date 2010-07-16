class CheckoutEvent < ActiveRecord::Base
  belongs_to :checkout
  belongs_to :user
  
  # this document refers to two users:
  # the "checkout user" is the person responsible for
  #   returning the item
  # the "checkout causer" is the person the user is
  #   returning the item to.
  # if we think about this in terms of laiability/chain-of-command:
  # user reports to causer causer reports to TC or DM.
  
  # except as noted, each of the following
  #   events may be created by the checkout user
  #   or the checkout causer
  # also noted are the quantity allowed of each type
  # Note: you may change the 0th element of each pair without
  #   harming validation, but you may NOT change the 1st.
  EVENT_TYPES = [
    ['Check Out','opened'],                 # ONE
    ['Check In','closed'],                  # ONE
    ['Pay For','paymentReceived'],          # MANY, causer-only
    ['Charge User','paymentRequired'],      # MANY*, causer-only
    ['Set Check-In Deadline','deadlined'],  # MANY**, causer-only
    ['Make a Note','noted']                 # MANY
  ]
  #ASK * Should a Checkout be allowed to have more than one
  # 'paymentRequired' event?
  # ** A Chekcout may have MANY 'deadlined' events, the
  # first being the original deadline, subsequent refer
  # to extensions (or contractions?) of that deadline
  
  validates_presence_of :checkout_id, :user_id
  validates_associated :checkout, :user
  validates_inclusion_of :event, :in => EVENT_TYPES.map{|e| e[1]}
  validate :event_type
  #TODO deal with notes
  validate :user_has_permission
  
  # returns the human-readable string associated with the
  # given EVENT_TYPE key
  def self.event_name(arg)
    return nil if arg.nil? or EVENT_TYPES.flatten.index(arg).nil?
    i = EVENT_TYPES.flatten.index(arg)-1
    return nil unless i % 2 == 0
    EVENT_TYPES.flatten[i]
  end
  
  def to_s
    name
  end

protected

  def event_type
    errors[:event] << "Checkout already has a '#{CheckoutEvent.event_name('opened')}' event" if event == 'opened' and checkout.has_event?('opened')
    errors[:event] << "Checkout already has a '#{CheckoutEvent.event_name('closed')}' event" if event == 'closed' and checkout.has_event?('closed')
    errors[:event] << "Not allowed to close Checkout: outstanding balance" if event == 'closed' and checkout.paymentReceived < checkout.paymentRequired
    #TODO ASK why else wouldn't we be able to close a checkout?
  end
  
  def user_has_permission
    #TODO depending on what event type this has, check if the user has permission to post the event
  end
end
