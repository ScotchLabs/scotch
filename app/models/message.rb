class Message < ActiveRecord::Base
  belongs_to :message_list
  belongs_to :sender, class_name: 'User'
  belongs_to :original, class_name: 'Message'
  has_many :recipients
  has_many :users, through: :recipients

  DISTRIBUTION_TYPES = ['scotch', 'email', 'email_all', 'text_message']
  
  after_commit :send_message
  after_commit :add_recipients
  # after_commit :notify
  
  validates_presence_of :text, :subject
  validates_inclusion_of :distribution, in: DISTRIBUTION_TYPES

  def multipart?
    !self.html_part.nil?
  end

  def distribution
    unless self.message_list.nil?
      self.message_list.distribution
    else
      super
    end
  end
  
  protected

  def add_recipients
    unless self.message_list.nil?
      logger.info "**YES IT IS**"
      self.message_list.recipients.each do |r|
        recipient = self.recipients.new
        recipient.user = r
        recipient.save
      end
    end
  end

  def send_message
    logger.info "***in function***"
    if self.distribution == 'email' || self.distribution == 'email_all'
      logger.info "***if passed***"
      MessageSendWorker.perform_async(self.id)
    end
  end
  
  def notify
    notification_text = "<i class='icon-envelope'></i> #{self.message_thread.subject} in #{self.group.short_name} has new messages."
    self.message_thread.members.each do |m|
      m.notify(self.group, self.message_thread, 'new_message', notification_text)
    end
  end
end
