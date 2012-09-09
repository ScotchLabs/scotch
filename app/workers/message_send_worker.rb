class MessageSendWorker
  include Sidekiq::Worker
  
  def perform(user_ids, message_id, delivery)
    @message = Message.find(message_id)
    @thread = @message.message_thread
    @users = User.where(id: user_ids)
    logger.info @thread.reply_type
    
    @users.each do |user|
      if delivery == 'text_message'
        
      elsif delivery == 'email' && (@thread.reply_type == 'all' || (@thread.reply_type == 'self' && ((@thread.messages.first.user == user && @message.target.nil?) || (!@message.target.nil? && @message.target == user) || (@thread.messages.first.user == @message.user && @message.target.nil?))))
        MessageMailer.message_email(user, @message, @thread).deliver
      end
    end
  end
end
