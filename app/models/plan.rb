class Plan < ActiveRecord::Base
  belongs_to :group
  has_many :tasks

  def complete?
    !self.completed_time.nil?
  end
end
