class Notification < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :source, polymorphic: true
  belongs_to :subject, polymorphic: true
  
  default_scope order('created_at DESC')
  scope :unread, where(read: false)
  scope :recent, lambda{ where(read: false) + where(read: true).limit(where(read: false).count % 10) }
end
