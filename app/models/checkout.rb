class Checkout < ActiveRecord::Base
  has_many :checkout_events, :dependent => :destroy
  
  # the person the item was checked out BY
  belongs_to :opener, :class_name => "User"
  # the person the item was checked out TO
  belongs_to :user
  belongs_to :group
  belongs_to :item

  attr_protected :opener_id
  
  after_create :create_open_event

  validates_presence_of :group, :user, :item, :opener
  validate :user_in_group
  validate :item_unavailable
  
  def checkout_time
    return nil unless has_event? "opened"
    events('opened').first.created_at
  end
  def checkin_time
    return nil unless has_event? "closed"
    events('closed').first.created_at
  end
  
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
    has_event? 'opened' and !has_event? 'closed'
  end
  
  def openable?
    if !has_event? 'opened'
      return true
    elsif has_event? 'closed'
      return false
    else # has 'opened' and does not have 'closed'
      return true
    end
  end
  
  def events(arg)
    checkout_events.select { |e| e.event == arg }
  end
  
  def overdue?
    return false unless has_deadline?
    DateTime.now > deadline
  end
  
  def has_deadline?
    has_event?('deadlined')
  end
  
  def deadline
    latestDeadlineEvent = events('deadlined').sort {|a, b|
      a.created_at <=> b.created_at
    }.last
    DateTime.parse latestDeadlineEvent.notes
  end
  
  def paymentRequired
    return 0 unless has_event? 'paymentRequired'
    latestPaymentRequiredEvent = events('paymentRequired').sort {|a, b|
      a.created_at <=> b.created_at
    }.last
    latestPaymentRequiredEvent.notes.to_f
  end
  
  def paymentReceived
    sum = 0
    events('paymentReceived').each do |e|
      sum = sum + e.notes.to_f
    end
    sum
  end
  
  def to_s
    "#{user} checked out #{item} for #{group}"
  end

  def item_catalog_number
    item.catalog_number if item
  end

  def item_catalog_number= (num)
    self.item = Item.find_by_catalog_number(num)
  end
  
private
  def user_in_group
    errors[:user] << "is not in group #{group}" unless user.active_groups.include? group
  end
  
  def item_unavailable
    errors[:item] << "is already checked out" unless item.available?
  end
  
  def create_open_event
    c = CheckoutEvent.new({:checkout_id => id, :event => 'opened'})
    c.user_id = opener_id
    unless c.save
      raise "Couldn't save a new '#{CheckoutEvent.event_name('opened')}' CheckoutEvent."
    end
  end
  
end
