class Checkout < ActiveRecord::Base

  has_many :checkout_events, :dependent => :destroy
  # http://guides.rails.info/association_basics.html#choosing-between-belongs-to-and-has-one
  belongs_to :user  # the user responsible for returning the item
  belongs_to :group # the group using the item,
                 # the group immediately in charge of authorizing the checkout
  belongs_to :item  # the item being checked out

  attr_protected :group_id

  validates_presence_of :group_id, :user_id, :item_id
  validates_associated :group, :user, :item

  attr_accessor :authorizer_id
  
  after_create :create_open_event
  
  # if arg is not specified, returns true if any CheckoutEvent
  # exists.
  # if arg is specified, searches for a CheckoutEvent
  # with that event, returns true if such a one exists
  # otherwise returns false.
  def has_event?(arg=nil)
    return true if events(arg).length > 0
    false
  end
  
  def open?
    !has_event?('closed')
  end
  
  def events(arg)
    checkout_events.map { |e| (e.event == arg)? (e):(nil) }.compact
  end
  
  def overdue?
    latestDeadlineEvent = events('deadlined').sort {|a,b|
      #TODO ASK how to deal with notes for separate COEs
    }.last
    #TODO ASK how to deal with notes for separate COEs
    # return date of deadlined > Time.now
  end
  
  #ASK should a Checkout be allowed to have
  # multiple 'paymentRequired' events?
  def paymentRequired
    sum = 0
    events('paymentRequired').each do |e|
      #TODO ASK how to deal with notes for separate COEs
    end
    sum
  end
  
  def paymentReceived
    sum = 0
    events('paymentReceived').each do |e|
      #TODO ASK how to deal with notes for separate COEs
    end
    sum
  end
  
  def to_s
    "#{user} checked out #{item} for #{group}"
  end
  
private
  
  def create_open_event
    c = CheckoutEvent.new({:user_id => authorizer_id, :checkout_id => id, :event => 'opened'})
    raise "Couldn't save a new '#{CheckoutEvent.event_name('opened')}' CheckoutEvent." unless c.save
  end
  
end
