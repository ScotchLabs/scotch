class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination, :counter_cache => true, :inverse_of => :votes
  has_one :race, :through => :nomination

  validates_presence_of :user
  validates_presence_of :nomination

  validate :only_vote_once

  def only_vote_once
    if nomination.race.voting.election?
      unless nomination.votes.where(:user_id => self.user_id).count == 0
        unless nomination.nominees.exists?(:user_id => self.user_id)
          errors[:base] << "You can't both nominate and second a nomination."
        end
      end
    elsif nomination.race.voting.award?
      unless nomination.race.votes.where(:user_id => self.user_id).count == 0
        errors[:base] << "you can't vote more than once."
      end
    end
  end
end
