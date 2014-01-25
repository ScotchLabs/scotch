class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :original, class_name: 'Message'
  has_many :recipients, as: :owner
  has_many :users, through: :recipients

  RECIPIENT_SQL = "
    (target_type = 'User' AND target_id = ?) OR
    (target_type = 'Group' AND (SELECT COUNT(*) FROM positions
    WHERE group_id = recipients.target_id AND user_id = ?) > 0) OR
    (target_type = 'Position' AND
    (SELECT COUNT(*) FROM positions
    WHERE display_name = recipients.target_identifier AND
    (recipients.group_id IS NULL OR group_id = recipients.group_id) AND
    user_id = ?) > 0) OR
    (target_type = 'Role' AND (SELECT COUNT(*) FROM positions
    WHERE role_id = recipients.target_id AND
    (recipients.group_id IS NULL OR group_id = recipients.group_id) AND
    user_id = ?) > 0)
  "


  validates_presence_of :text, :subject

  attr_accessor :recipients_field

  def to
    recipients.collect(&:to).compact.join(', ')
  end

  def recipients_for_user(user)
    recipients.where(RECIPIENT_SQL, user.id, user.id,
                     user.id, user.id)
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
