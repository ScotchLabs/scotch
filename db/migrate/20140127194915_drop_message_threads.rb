class DropMessageThreads < ActiveRecord::Migration
  def up
    drop_table :message_threads
  end

  def down
    create_table :message_threads do |t|
      t.string :subject
      t.integer :group_id
      t.string :privacy, default: 'none'
      t.boolean :deleted, default: false
      t.string :reply_type, default: 'self'
    end
  end
end
