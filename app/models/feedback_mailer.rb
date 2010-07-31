class FeedbackMailer < ActionMailer::Base
  
  def feedback(feedback)
    @recipients  = 'web@snstheatre.org'
    @from        = 'webmaster@snstheatre.org'
    @subject     = "[Scotch] Feedback: #{feedback.subject}"
    @sent_on     = Time.now
    @body[:feedback] = feedback
  end

end
