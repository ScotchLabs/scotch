class AddPrivacyToMessageThreads < ActiveRecord::Migration
  def change
    add_column :message_threads, :privacy, :string, default: 'none'
  end
end
