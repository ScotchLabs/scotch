class CreateMessageLists < ActiveRecord::Migration
  def change
    create_table :message_lists do |t|
      t.integer :group_id
      t.string :name
      t.string :address
      t.string :distribution, default: 'email'
      t.boolean :entire_group, default: false
      t.string :security

      t.timestamps
    end
  end
end
