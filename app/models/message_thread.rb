class MessageThread < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users
  has_many :messages
  
  def recent_message
    if self.messages.count > 0
      self.messages.last
    else
      false
    end
  end
end
