class MessageThread < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users, uniq: true
  has_many :messages, dependent: :destroy
  has_many :participants, through: :messages, source: :user, uniq: true
  
  COLORS = {'none' => 'success', 'group' => 'info', 'private' => 'inverse'}
  
  validates_inclusion_of :privacy, in: ['none', 'group', 'private']
  validates_inclusion_of :reply_type, in: ['none', 'self', 'all']
  validates_presence_of :message, :subject
  
  before_update :record_old_members
  after_commit :add_new_members
  after_commit :notify_new_members
  after_commit :send_first_message
  
  default_scope where(deleted: false)
  
  attr_accessor :old_members, :new_members, :first_message, :first_message_priority, :first_message_sender
  
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

  def message=(message_text)
    self.first_message = message_text
  end

  def message
    self.messages.count > 0 ? self.messages.first.text : nil
  end

  def priority=(message_priority)
    self.first_message_priority = message_priority
  end

  def priority
    self.messages.count > 0 ? self.messages.first.priority : nil
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

  def recipients
    result = []

    self.users.each do |u|
      result << {id: "user:#{u.id}", name: u.name}
    end

    result
  end

  def recipients=(recipient_ids)
    recipient_ids = recipient_ids.split(',')
    self.new_members = []

    recipient_ids.each do |r|
      ident_type, ident_id = r.split(':')
      if ident_type == 'user'
        self.new_members << ident_id
      else

      end
    end
  end
  
  protected
  
  def record_old_members
    if self.privacy == 'private'
      self.old_members = self.members
    end
  end

  def add_new_members
    if !new_members.nil? && new_members.count > 0
      self.users.clear
      new_members.each do |m|
        self.users << User.find(m)
      end
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

  def send_first_message
    if self.first_message && self.first_message_priority
      self.messages.create(text: self.first_message, priority: self.first_message_priority, user: self.first_message_sender)
    end
  end
end
