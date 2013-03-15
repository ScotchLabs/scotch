class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :address
      t.integer :order_number
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
