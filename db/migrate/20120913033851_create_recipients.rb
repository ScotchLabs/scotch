class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.integer :message_list_id
      t.integer :message_id
      t.integer :target_id
      t.string :target_type
      t.boolean :message_sent

      t.timestamps
    end
  end
end
