class Checkout < ActiveRecord::Base

  has_many :checkout_events
  has_one :user
  has_one :group

  attr_protected :group_id

end
