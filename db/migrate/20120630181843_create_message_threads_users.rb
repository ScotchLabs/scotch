class CreateMessageThreadsUsers < ActiveRecord::Migration
  def change
    create_table :message_threads_users, id: false do |t|
      t.integer :message_thread_id
      t.integer :user_id

      t.timestamps
    end
  end
end
