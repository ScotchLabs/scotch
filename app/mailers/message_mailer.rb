class MessageMailer < ActionMailer::Base
  default from: "no-reply@snstheatre.org"
  
  def message_email(user, message, list, opts={})
    @user = user
    @message = message
    @list = list

    if @list
      headers['List-ID'] = "reefer+production@snstheatre.org"
      headers['List-Post'] = "reefer+production@snstheatre.org"
    end

    mail(from: @message.sender.email,
         to: @user.email,
         subject: @message.subject)
  end

  def subscribe_email(contact, opts={})
    email = contact.email

    mail(to: email,
         subject: "Scotch'n'Soda Public Mailing List")
  end
end
