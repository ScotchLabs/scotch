class CreateTicketReservations < ActiveRecord::Migration
  def change
    create_table :ticket_reservations do |t|
      t.integer :event_id
      t.integer :owner_id
      t.string :owner_type
      t.integer :amount
      t.integer :amount_claimed, default: 0
      t.integer :waitlist_amount, default: 0
      t.boolean :with_id, default: false
      t.boolean :cancelled, default: false

      t.timestamps
    end
  end
end
