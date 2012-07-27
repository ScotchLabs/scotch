class Message < ActiveRecord::Base
  belongs_to :message_thread
  belongs_to :user
  has_one :group, through: :message_thread
  
  after_commit :send_message
  after_commit :notify
  
  validates_inclusion_of :priority, in: ['none', 'email', 'text_message']
  
  protected
  
  def send_message
    self.message_thread.members.each do |member|
      if self.priority == 'text_message'
        #Send a text with Twilio, GitHub Issue #86
        logger.info 'Would send out TEXT'
      elsif member.settings.default_priority == 'email' || self.priority == 'email'
        MessageSendWorker.perform_async(self.message_thread.members.pluck('users.id'), self.id, 'email')
      end
    end
  end
  
  def notify
    notification_text = "<i class='icon-envelope'></i> #{self.message_thread.subject} in #{self.group.short_name} has new messages."
    self.message_thread.members.each do |m|
      m.notify(self.group, self.message_thread, 'new_message', notification_text)
    end
  end
end
