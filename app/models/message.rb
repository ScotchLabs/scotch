class Message < ActiveRecord::Base
  belongs_to :message_list
  belongs_to :sender, class_name: 'User'
  belongs_to :original, class_name: 'Message'
  has_many :recipients

  DISTRIBUTION_TYPES = ['scotch', 'email', 'email_all', 'text_message']
  
  after_commit :send_message
  after_commit :notify
  
  validates_presence_of :text, :subject
  validates_inclusion_of :distribution, in: DISTRIBUTION_TYPES
  
  protected
  
  def send_message
    if self.priority == 'text_message'
      #Send a text with Twilio, GitHub Issue #86
      logger.info 'Would send out TEXT'
    elsif self.priority == 'email' || self.message_thread.reply_type != 'none'
      MessageSendWorker.perform_async(self.message_thread.members.pluck('users.id'), self.id, 'email')
    end
  end
  
  def notify
    notification_text = "<i class='icon-envelope'></i> #{self.message_thread.subject} in #{self.group.short_name} has new messages."
    self.message_thread.members.each do |m|
      m.notify(self.group, self.message_thread, 'new_message', notification_text)
    end
  end
end
