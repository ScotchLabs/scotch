class DropMessageThreadsUsers < ActiveRecord::Migration
  def up
    drop_table :message_threads_users
  end

  def down
    create_table :message_threads_users, id: false do |t|
      t.integer :message_thread_id
      t.integer :user_id

      t.timestamps
    end
  end
end
