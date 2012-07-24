class Message < ActiveRecord::Base
  belongs_to :message_thread
  belongs_to :user
  
  after_commit :send_message
  
  validates_inclusion_of :priority, in: ['none', 'email', 'text_message']
  
  protected
  
  def send_message
    self.message_thread.members.each do |member|
      if self.priority == 'text_message'
        #Send a text with Twilio, GitHub Issue #86
        logger.info 'Would send out TEXT'
      elsif member.settings.default_priority == 'email' || self.priority == 'email'
        #Send an email, GitHub Issue #84
        MessageSendWorker.perform_async(self.message_thread.members.pluck('users.id'), self.id, 'email')
      end
    end
  end
end
