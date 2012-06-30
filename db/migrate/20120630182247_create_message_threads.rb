class CreateMessageThreads < ActiveRecord::Migration
  def change
    create_table :message_threads do |t|
      t.string :subject
      t.integer :group_id

      t.timestamps
    end
  end
end
