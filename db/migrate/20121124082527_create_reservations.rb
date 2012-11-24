class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.integer :item_id
      t.integer :allocation_id
      t.integer :start_quantity
      t.integer :end_quantity
      t.date :return_date

      t.timestamps
    end
  end
end
