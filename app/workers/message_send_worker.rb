class MessageSendWorker
  include Sidekiq::Worker
  require 'letter_opener' if Rails.env.development?
  
  def perform(message_id)
    logger.info "Message id: #{message_id}"
    @message = Message.find(message_id)
    @users = @message.distribution == 'email_all' ? @message.message_list.group.members : @message.users
    @list = @message.message_list ? @message.message_list : false
    
    @users.each do |user|
      if ['email', 'email_all'].include? @message.distribution
        mail = Mail.new
        mail.from = @message.sender.email
        mail.to = @list ? "#{@list.group.short_name}+#{@list.address}@snstheatre.org" : user.email
        mail.subject = @list ? "[#{@list.group.short_name.capitalize} #{@list.name}] " + @message.subject : @message.subject
        mail.envelope_recipient = user.email

        text_part = Mail::Part.new
        text_part.body  = @message.text
        mail.text_part = text_part

        if @message.multipart?
          html_part = Mail::Part.new
          html_part.content_type = 'text/html; charset=UTF-8'
          html_part.body = @message.html_part
          mail.html_part = html_part
        end

        mail.delivery_method LetterOpener::DeliveryMethod, :location => File.join(File.dirname(__FILE__), '/../', 'tmp', 'letter_opener') if Rails.env.development?
        mail.delivery_method :smtp, ssl: false, tls: false if Rails.env.production?
        mail.deliver
      end
    end
  end
end
