class MessageReceiveWorker
  include Sidekiq::Worker
  
  def perform(to, from, message)
    user_id = to.scan(/-(\d+)@/).first.first
    thread_id = to.scan(/\+(\d+)-/).first.first
    
    user = User.find(user_id)
    thread = MessageThread.find(thread_id)
    
    #Experimental method of removing quoted reply text
    filtered_message = message.scan(/(.*)\n.*#{Regexp.escape(to)}/m).first
    
    if filtered_message
      filtered_message = filtered_message.first
    else
      filtered_message = MailExtract.new(message).body
    end
    
    if thread.privacy == 'open' || thread.members.include?(user)
      priority = thread.reply_type != 'none' ? 'email' : 'none'
      thread.messages.create(user_id: user.id, text: filtered_message, priority: priority)
    end
    
    #TODO: Push to users via Faye
  end
end
