class Checkout < ActiveRecord::Base

  has_many :checkout_events, :dependent => :destroy
  has_one :user
  has_one :group

  attr_protected :group_id

  validates_presence_of :group, :user
end
