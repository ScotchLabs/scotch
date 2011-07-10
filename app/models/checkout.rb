# == Schema Information
#
# Table name: checkouts
#
#  id            :integer(4)      not null, primary key
#  group_id      :integer(4)
#  user_id       :integer(4)
#  item_id       :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  opener_id     :integer(4)
#  checkout_date :date
#  checkin_date  :date
#  due_date      :date
#  notes         :text
#

class Checkout < ActiveRecord::Base
  # the person the item was checked out TO
  belongs_to :user
  belongs_to :item

  attr_protected :opener_id

  before_create :set_checkout_date
  
  validates_presence_of :group, :user, :item, :opener
  validate :item_unavailable, :on => :create
  
  def open?
    checkin_date.nil?
  end
  
  def overdue?
    DateTime.zone.now > due_date
  end
  
  def to_s
    "#{user} checked out #{item}"
  end

  def item_catalog_number
    item.catalog_number if item
  end

  def item_catalog_number= (num)
    self.item = Item.find_by_catalog_number(num)
  end
  
private
  
  def item_unavailable
    errors[:item] << "is already checked out" unless item.available?
  end

  def set_checkout_date
    self.checkout_date = DateTime.now
  end
  
end
