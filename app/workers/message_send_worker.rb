class MessageSendWorker
  include Sidekiq::Worker
  require 'letter_opener' if Rails.env.development?
  
  def perform(message_id)
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

        mail.delivery_method LetterOpener::DeliveryMethod, :location => File.join(File.dirname(__FILE__), '/../', 'tmp', 'letter_opener') if Rails.env.development?
        mail.deliver
      end
    end
  end
end
