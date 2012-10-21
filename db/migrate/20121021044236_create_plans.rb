class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :group_id
      t.integer :event_id
      t.string :name
      t.datetime :start_date
      t.datetime :due_date

      t.timestamps
    end
  end
end
