class AddReplyTypeToMessageThreads < ActiveRecord::Migration
  def change
    add_column :message_threads, :reply_type, :string, default: 'self'
  end
end
