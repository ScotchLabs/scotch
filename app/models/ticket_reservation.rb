class TicketReservation < ActiveRecord::Base
  belongs_to :event
  belongs_to :owner, polymorphic: true

  validates_presence_of :event_id, :owner_id, :amount, :name, :email
  validates_numericality_of :amount, greater_than: 0
  validate :ticketing_open
  validate :tickets_available

  scope :active, where(cancelled: false)
  scope :with_id, where(with_id: true)

  attr_writer :name, :email
  attr_protected :waitlist_amount, :confirmation_code

  delegate :show_time, to: :event

  before_create :generate_confirmation_code

  def self.tickets
    sum(:amount)
  end

  #REPLACE by normalizing Event
  def group
    self.event.owner
  end

  def name
    self.owner.try(:name) || @name
  end

  def email
    self.owner.try(:email) || @email
  end

  def to_param
    self.confirmation_code
  end

  protected

  def generate_confirmation_code
    self.confirmation_code = (0..8).map{ (65+rand(26)).chr }.join
  end

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
