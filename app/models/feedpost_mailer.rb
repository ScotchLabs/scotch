class FeedpostMailer < ActionMailer::Base
  default :from => "webmaster@snstheatre.org"
  
  def user_notification(feedpost, user)
    @user = user
    @feedpost = feedpost
    mail(:to => user.email,
         :subject => "[Scotch] new post on your wall: #{feedpost.headline}")
  end

  def group_notification(feedpost, user)
    @user = user
    @feedpost = feedpost
    mail(:to => user.email,
         :subject => "[Scotch] new on the wall for #{feedpost.parent.short_name}")
  end

end
