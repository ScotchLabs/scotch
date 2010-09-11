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
    mail(:bcc => emails,
         :subject => "[Scotch] #{feedpost.parent.short_name}: #{feedpost.headline}")
  end

end
