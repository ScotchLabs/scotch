class CreateAllocations < ActiveRecord::Migration
  def change
    create_table :allocations do |t|
      t.integer :reserver_id
      t.integer :group_id
      t.date :start_date
      t.date :end_date
      t.date :return_date
      t.text :reason
      t.boolean :approved

      t.timestamps
    end
  end
end
