class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :thread_id
      t.integer :user_id
      t.text :text
      t.string :priority

      t.timestamps
    end
  end
end
