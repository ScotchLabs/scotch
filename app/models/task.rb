class Task < ActiveRecord::Base
  belongs_to :plan
  belongs_to :manager, class_name: 'User'

  def complete?
    !self.completed_time.nil?
  end

  def status
    if self.complete?
      'complete'
    elsif DateTime.now > self.start_time
      'inprogress'
    else
      'notstarted'
    end
  end
end
