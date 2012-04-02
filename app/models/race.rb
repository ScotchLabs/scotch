class Race < ActiveRecord::Base
  belongs_to :voting
  has_many :nominations
end
