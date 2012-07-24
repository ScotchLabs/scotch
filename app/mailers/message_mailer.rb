class MessageMailer < ActionMailer::Base
  default from: "no-reply@snstheatre.org"
  
  def message_email(user, message, thread)
    @user = user
    @message = message
    @thread = thread
    
    from = 'thread+' + @thread.id.to_s + '-' + @user.id.to_s + '@snstheatre.org'
    
    mail(
      from: from,
      to: @user.email,
      subject: @thread.subject
    )
  end
end
