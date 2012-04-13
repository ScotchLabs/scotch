class Vote < ActiveRecord::Base
  belongs_to :voter
  belongs_to :nomination, :counter_cache => true
end
