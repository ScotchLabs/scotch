class CreateCheckoutEvents < ActiveRecord::Migration
  def self.up
    create_table :checkout_events do |t|
      t.string :event
      t.integer :user_id
      t.string :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :checkout_events
  end
end
