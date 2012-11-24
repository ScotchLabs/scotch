class Allocation < ActiveRecord::Base
  has_many :reservations
  has_many :items, through: :reservations
end
