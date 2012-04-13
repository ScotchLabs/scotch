class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination, :counter_cache => true
end
