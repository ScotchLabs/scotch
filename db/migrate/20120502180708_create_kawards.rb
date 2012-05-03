class CreateKawards < ActiveRecord::Migration
  def self.up
    create_table :kawards do |t|
      t.integer :kudo_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :kawards
  end
end
