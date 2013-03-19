class AddTicketingToEvents < ActiveRecord::Migration
  def change
    add_column :events, :attendance_count, :integer
    add_column :events, :max_attendance, :integer
  end
end
