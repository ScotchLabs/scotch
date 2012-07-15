class Message < ActiveRecord::Base
  belongs_to :message_thread
  belongs_to :user
  
  validates_inclusion_of :priority, in: ['none', 'email', 'text_message']
end
