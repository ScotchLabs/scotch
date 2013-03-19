class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :user_id
      t.string :protocol
      t.string :address
      t.string :temporary_name

      t.timestamps
    end
  end
end
