class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.integer :area_id
      t.string :item_type
      t.text :description

      t.timestamps
    end
  end
end
