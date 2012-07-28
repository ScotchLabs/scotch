class MessageThread < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users, uniq: true
  has_many :messages, dependent: :destroy
  has_many :participants, through: :messages, source: :user, uniq: true
  
  COLORS = {'none' => 'success', 'group' => 'info', 'private' => 'inverse'}
  
  validates_inclusion_of :privacy, in: ['none', 'group', 'private']
  
  before_update :record_old_members
  after_commit :notify_new_members
  
  default_scope where(deleted: false)
  
  attr_accessor :old_members
  
  #Returns all threads that should be visible to user/group
  def self.visible(user, vis_group = false)
    where do
      if vis_group
        (group_id == vis_group.id) &
        ((privacy != 'closed') |
        (id.in user.message_threads.select(:id)))
      else
        (((privacy == 'open') | (privacy == 'group')) &
        (group_id.in user.groups.select(:id))) |
        ((privacy != 'closed') |
        (id.in user.message_threads.select(:id)))
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
  
  protected
  
  def record_old_members
    if self.privacy == 'private'
      self.old_members = self.members
    end
  end
  
  def notify_new_members
    new_members = []
    
    if self.privacy == 'private'
      new_members = self.old_members ? self.members - self.old_members : self.members
      notification_text = "<i class='icon-envelope'></i> You have been added to #{self.subject} in #{self.group.short_name}."
      new_members.each do |m|
        m.notify(self.group, self, 'new_member', notification_text)
      end
    end
  end
end
