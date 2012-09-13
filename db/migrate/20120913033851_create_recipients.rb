class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.integer :message_list_id
      t.integer :message_id
      t.integer :user_id
      t.boolean :message_sent

      t.timestamps
    end
  end
end
