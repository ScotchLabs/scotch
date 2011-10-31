class FeedpostMailer < ActionMailer::Base
  default :from => "webmaster@snstheatre.org"
  
  def user_notification(feedpost, user)
    @user = user
    @feedpost = feedpost
    mail(:to => user.email,
         :subject => "[Scotch] new post on your wall: #{feedpost.headline}")
  end

  def group_notification(feedpost, emails)
    @feedpost = feedpost
    if feedpost.parent.class == Show and emails.size < 20
      mail(:to => emails,
           :from => "\"#{feedpost.user.name}\" <#{feedpost.user.email}>",
           :cc => "\"#{feedpost.user.name}\" <#{feedpost.user.email}>",
           :subject => "[Scotch] #{feedpost.parent.short_name}: #{feedpost.headline}")
    else
      mail(:bcc => emails,
           :to => "\"#{feedpost.parent.name}\" <noreply@snstheatre.org>",
           :from => "\"#{feedpost.user.name}\" <#{feedpost.user.email}>",
           :cc => "\"#{feedpost.user.name}\" <#{feedpost.user.email}>",
           :subject => "[Scotch] #{feedpost.parent.short_name}: #{feedpost.headline}")
    end
  end

end
