class ChangeThreadToMesssageThread < ActiveRecord::Migration
  def change
    remove_column :messages, :thread_id
    add_column :messages, :message_thread_id, :integer
  end
end
