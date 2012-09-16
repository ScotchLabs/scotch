class Message < ActiveRecord::Base
  belongs_to :message_list
  belongs_to :sender, class_name: 'User'
  belongs_to :original, class_name: 'Message'
  has_many :recipients
  has_many :users, through: :recipients

  DISTRIBUTION_TYPES = ['scotch', 'email', 'email_all', 'text_message']
  
  after_commit :add_recipients
  after_commit :send_message
  after_commit :notify
  
  validates_presence_of :text, :subject
  validates_inclusion_of :distribution, in: DISTRIBUTION_TYPES
  
  protected

  def add_recipients
    unless self.message_list_id.nil?
      self.message_list.recipients.each do |r|
        recipient = Recipient.new
        recipient.user = r.user
        self.recipients << recipient
      end
    end
  end

  def send_message
    if self.distribution == 'email' || self.distribution == 'email_all'
      MessageSendWorker.perform_async(self.users.pluck('users.id'), self.id, 'email')
    end
  end
  
  def notify
    notification_text = "<i class='icon-envelope'></i> #{self.message_thread.subject} in #{self.group.short_name} has new messages."
    self.message_thread.members.each do |m|
      m.notify(self.group, self.message_thread, 'new_message', notification_text)
    end
  end
end
