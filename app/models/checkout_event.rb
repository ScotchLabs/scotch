class CheckoutEvent < ActiveRecord::Base
  belongs_to :checkout
  belongs_to :user

  validates_presence_of :checkout_id, :user_id
end
