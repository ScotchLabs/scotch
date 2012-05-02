class Knomination < ActiveRecord::Base
  belongs_to :kaward
  has_one :kudo, :through => :kaward
  has_and_belongs_to_many :users
  
  has_and_belongs_to_many :nominators, :class_name => 'User', :join_table => 'nominators', :uniq => true
  
  def nomination
    self.content
  end
end