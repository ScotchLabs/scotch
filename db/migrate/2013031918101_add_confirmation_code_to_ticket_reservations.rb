class AddConfirmationCodeToTicketReservations < ActiveRecord::Migration
  def change
    add_column :ticket_reservations, :confirmation_code, :string
    add_index :ticket_reservations, :confirmation_code
  end
end
