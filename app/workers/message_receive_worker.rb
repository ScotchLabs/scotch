class MessageReceiveWorker
  include Sidekiq::Worker
  
  def perform(to, from, text_part, html_part)
    group_name = to.scan(/^(\w+)+/).first.first
    list_name = to.scan(/\+(\w+)@/).first.first
    
    user = User.find_by_email(from)
    list = MessageList.where(name: list_name, group: Group.find_by_short_name(group_name))


  end
end
