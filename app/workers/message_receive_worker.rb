class MessageReceiveWorker
  include Sidekiq::Worker
  
  def perform(to, from, subject, text_part, html_part = nil)
    group_name = to.scan(/^(\w+)+/).first
    list_name = to.scan(/\+(\w+)@/).first

    group_name = group_name ? group_name.first : nil
    list_name = list_name ? list_name.first : nil
    
    user = User.find_by_email(from)
    list = MessageList.where(address: list_name.downcase, group_id: Group.find_by_short_name(group_name)).first if list_name && group_name

    if user.nil?
      MessageList.error_reply(from, "This email address is not recognized by Scotch. Please make sure you are using the same email you use on Scotch.")
    elsif list.nil?
      MessageList.error_reply(from, "This message list #{group_name}+#{list_name} does not exist. Please check the email list name.")
    elsif !list.can_post?(user)
      MessageList.error_reply(from, "You are not authorized to transmit on this email list")
    else
      message = list.messages.new(text: text_part, subject: subject, html_part: html_part)
      message.sender = user
      message.save
    end
  end
end
