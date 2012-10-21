class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :plan_id
      t.integer :event_id
      t.integer :manager_id
      t.string :name
      t.string :description
      t.integer :required_personnel
      t.integer :number
      t.string :skills_required
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :completed_time

      t.timestamps
    end
  end
end
