class Nomination < ActiveRecord::Base
  belongs_to :race
  has_many :nominees
  has_many :users, :through => :nominees
end
