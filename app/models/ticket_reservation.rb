class TicketReservation < ActiveRecord::Base
  belongs_to :event
  belongs_to :owner, polymorphic: true

  validates_presence_of :event_id, :owner_id, :amount, :name, :email
  validates_numericality_of :amount, greater_than: 0
  validate :ticketing_open
  validate :tickets_available

  scope :active, where(cancelled: false)
  scope :with_id, where(with_id: true)

  attr_accessor :name, :email
  attr_protected :waitlist_amount

  def self.tickets
    sum(:amount)
  end

  def name
    self.owner.try(:name)
  end

  def email
    self.owner.try(:email)
  end

  protected

  def ticketing_open
    unless self.event.tickets_available?
      self.errors.add(:event_id, "ticketing isn't open")
      false
    else
      true
    end
  end

  def tickets_available
    if !self.cancelled && self.event.available_tickets < self.amount
      self.errors.add(:amount, "is too big. Only #{self.event.available_tickets} left for this performance.")
      false
    else
      true
    end
  end
end
