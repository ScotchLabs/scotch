class Knomination < ActiveRecord::Base
  belongs_to :kaward
  has_one :kudo, :through => :kaward
  has_and_belongs_to_many :users
  has_many :kvotes
  
  has_and_belongs_to_many :nominators, :class_name => 'User', :join_table => 'nominators', :uniq => true
  validates_presence_of :content
  validates_uniqueness_of :content, :scope => [:kaward_id, :deleted], :if => :not_deleted?
  
  default_scope where(:deleted => false)
  
  after_save :link_users
  
  def nomination
    self.content
  end
  
  def not_deleted?
    !self.deleted
  end
  
  def votes
    self.kvotes.where(:positive => true, :stage => nil).count - self.kvotes.where(:positive => false, :stage => nil).count
  end
  
  private
  
  def link_users
    self.users.clear
    self.content.scan(/@(.)\s/).each do |u|
      self.users << User.find_by_andrewid(u) if User.exists?(:andrewid => u)
    end
  end
end