class Knomination < ActiveRecord::Base
  belongs_to :kaward
  has_one :kudo, :through => :kaward
  has_and_belongs_to_many :users
  has_many :kvotes
  
  has_and_belongs_to_many :nominators, :class_name => 'User', :join_table => 'nominators', :uniq => true
  validates_presence_of :content
  validates_uniqueness_of :content
  
  after_save :link_users
  
  def nomination
    self.content
  end
  
  private
  
  def link_users
    self.users.clear
    self.content.scan(/@(.)\s/).each do |u|
      self.users << User.find_by_andrewid(u) if User.exists?(:andrewid => u)
    end
  end
end