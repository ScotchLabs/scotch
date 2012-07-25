class MessageReceiveWorker
  include Sidekiq::Worker
  
  def perform(raw_email)
    email = Mail.read_from_string(raw_email)
    to = email.to.first
    from = email.from.first
    
    message = ""
    
    if email.multipart?
      part = email.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
      unless part.nil?
        message = part.body.decoded
      end
    else
      message = part.body.decoded
    end
    
    user_id = to.scan(/-(\d+)@/).first.first
    thread_id = to.scan(/\+(\d+)-/).first.first
    
    user = User.find(user_id)
    thread = MessageThread.find(thread_id)
    
    #Experimental method of removing quoted reply text
    message = message.scan(/(.*)\n.*#{Regexp.escape(to)}/m).first.first
    
    #TODO: Implement a check for whether they are allowed to post in this thread
    thread.messages.create(user_id: user.id, text: message, priority: 'none')
    
    #TODO: Push to users via Faye
  end
end