class CreateListMembers < ActiveRecord::Migration
  def change
    create_table :list_members do |t|
      t.integer :message_list_id
      t.integer :member_id
      t.string :member_type

      t.timestamps
    end
  end
end
