class MessageThread < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users
  has_many :messages, dependent: :destroy
  has_many :participants, through: :messages, source: :user, uniq: true
  
  COLORS = {'none' => 'success', 'group' => 'info', 'private' => 'inverse'}
  
  validates_inclusion_of :privacy, in: ['none', 'group', 'private']
  
  #Returns all threads that should be visible to user/group
  def self.visible(user, vis_group = false)
    where do
      if vis_group
        (group_id == vis_group.id) &
        ((privacy != 'closed') |
        (id.in user.message_threads.select(:id)))
      else
        (id.in user.message_threads.select(:id))
      end
    end
  end
  
  def recent_message
    if self.messages.count > 0
      self.messages.last
    else
      false
    end
  end
  
  def members
    if self.privacy == 'private'
      self.users
    elsif self.privacy == 'group'
      self.group.members
    else
      self.participants
    end
  end
  
  def members=(user_ids)
    
  end
end
