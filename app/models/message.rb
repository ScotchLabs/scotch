class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :original, class_name: 'Message'
  has_many :recipients
  has_many :users, through: :recipients

  validates_presence_of :text, :subject

  attr_accessor :recipients_field

  def to
    recipients.collect(&:to)
  end

  def multipart?
    !self.html_part.nil?
  end

  def preview
    "#{self.text[0..150]}#{self.text.length > 150 ? '...' : ''}"
  end

  def deliver
    send_message
  end
  
  protected

  def send_message
    logger.info "Message ID: #{self.id} Sending"
    MessageSendWorker.perform_async(self.id)
  end
end
