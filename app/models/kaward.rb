class Kaward < ActiveRecord::Base
  belongs_to :kudo
  has_many :knominations
  
  has_and_belongs_to_many :voters, :class_name => 'User', :join_table => 'voters', :uniq => true
end