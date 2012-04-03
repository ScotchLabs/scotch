class CreateNominees < ActiveRecord::Migration
  def self.up
    create_table :nominees do |t|
      t.references :user
      t.references :nomination

      t.timestamps
    end
  end

  def self.down
    drop_table :nominees
  end
end
