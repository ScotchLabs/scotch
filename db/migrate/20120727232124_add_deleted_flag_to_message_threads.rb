class AddDeletedFlagToMessageThreads < ActiveRecord::Migration
  def change
    add_column :message_threads, :deleted, :boolean, default: false

  end
end
