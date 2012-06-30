class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :user_id
      t.string :default_priority

      t.timestamps
    end
  end
end
