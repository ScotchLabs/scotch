class Kudo < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  has_many :knominations
  has_many :kawards
  
  accepts_nested_attributes_for :kawards
  
  #Nominations open, voting open, closed
  def status
    if Time.now < self.nominations_open
      "Nominations will open in #{time_ago_in_words(self.nominations_open)}"
    elsif Time.now < self.start
      "Nominations will close in #{time_ago_in_words(self.start)}"
    elsif Time.now < self.end
      "Voting will close in #{time_ago_in_words(self.end)}"
    else
      "Voting closed #{time_ago_in_words(self.end)} ago"
    end
  end
  
  def name
    "Kudos #{self.woodscotch.month < 6 ? 'Spring' : 'Fall'} #{self.woodscotch.year}"
  end
  
  def nominations_open?
    self.nominations_open < Time.now && Time.now < self.start
  end
  
  def voting_open?
    self.start < Time.now && Time.now < self.end
  end
end
