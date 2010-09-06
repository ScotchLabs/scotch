class Checkout < ActiveRecord::Base
  has_many :checkout_events, :dependent => :destroy
  
  # the person the item was checked out BY
  belongs_to :opener, :class_name => "User"
  # the person the item was checked out TO
  belongs_to :user
  belongs_to :group
  belongs_to :item

  attr_protected :opener_id

  before_create :set_checkout_date
  
  validates_presence_of :group, :user, :item, :opener
  #validate :user_in_group, :on => :create
  validate :item_unavailable, :on => :create
  
  def open?
    checkin_date.nil?
  end
  
  def overdue?
    DateTime.zone.now > due_date
  end
  
  def has_deadline?
    not due_date.nil?
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

  def set_checkout_date
    self.checkout_date = DateTime.now
  end
  
end
