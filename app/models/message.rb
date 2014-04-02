require 'mailgunner'
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

    mail = Mail.new
    mail.from = "#{self.sender.name} <#{self.sender.email}>"

    text_part = Mail::Part.new
    text_part.body  = self.text
    mail.text_part = text_part

    if self.multipart?
      html_part = Mail::Part.new
      html_part.content_type = 'text/html; charset=UTF-8'
      html_part.body = self.html_part
      mail.html_part = html_part
    end

    mail.delivery_method Mailgunner::DeliveryMethod, {domain: 'sandbox14476fcd299e4b2499dabf21ce22f006.mailgun.org'}
    mail.delivery_method LetterOpener::DeliveryMethod, :location => File.join(File.dirname(__FILE__), '/../', 'tmp', 'letter_opener') if Rails.env.development?

    sent_to = [] # Tracks emails we already sent messages to

    self.recipients.each do |recipient|
      mail.subject = recipient.subject

      recipient.envelope_recipients.flatten.each do |email|
        if !sent_to.include?(email)
          mail.to = email
          mail.deliver
          sent_to << email
          mail.to = nil
        end
      end
    end
  end
end
