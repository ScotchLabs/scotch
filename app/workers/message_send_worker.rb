class MessageSendWorker
  include Sidekiq::Worker
  require 'letter_opener' if Rails.env.development?
  
  def perform(message_id)
    logger.info "Message id: #{message_id}"
    @message = Message.find(message_id)
    
    mail = Mail.new
    mail.from = "#{@message.sender.name} <#{@message.sender.email}>"
    mail.to = @message.to

    text_part = Mail::Part.new
    text_part.body  = @message.text
    mail.text_part = text_part

    if @message.multipart?
      html_part = Mail::Part.new
      html_part.content_type = 'text/html; charset=UTF-8'
      html_part.body = @message.html_part
      mail.html_part = html_part
    end

    mail.delivery_method :smtp, {enable_starttls_auto: false}
    mail.delivery_method LetterOpener::DeliveryMethod, :location => File.join(File.dirname(__FILE__), '/../', 'tmp', 'letter_opener') if Rails.env.development?

    sent_to = [] # Tracks emails we already sent messages to

    @message.recipients.each do |recipient|
      mail.subject = recipient.subject

      recipient.envelope_recipients.flatten.each do |email|
        if !sent_to.include?(email)
          mail.envelope_recipient = email
          mail.deliver
          sent_to << email
          mail.envelope_recipient = nil
        end
      end
    end
  end
end
