class Kaward < ActiveRecord::Base
  belongs_to :kudo
  has_many :knominations
  has_many :kvotes, :through => :knominations
  
  has_and_belongs_to_many :voters, :class_name => 'User', :join_table => 'voters', :uniq => true

  def voting_knominations
    self.knominations.joins(:kvotes).where('kvotes.stage IS NULL AND kvotes.positive = TRUE').group('knominations.id').order('COUNT(kvotes.id) DESC').limit(3)
  end
end
