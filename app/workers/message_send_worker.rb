class MessageSendWorker
  include Sidekiq::Worker
  
  def perform(user_ids, message_id, delivery)
    @message = Message.find(message_id)
    @thread = @message.message_thread
    @users = User.where(id: user_ids)
    
    if delivery == 'email'
      sendEmail
    elsif delivery == 'text_message'
      sendText
    end
  end
  
  def sendEmail
    @users.each do |user|
      MessageMailer.message_email(user, @message, @thread).deliver
    end
  end
  
  def sendText
    
  end
end