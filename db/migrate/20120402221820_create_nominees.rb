class CreateNominees < ActiveRecord::Migration
  def self.up
    create_table :nominees do |t|
      t.reference :user
      t.reference :nomination

      t.timestamps
    end
  end

  def self.down
    drop_table :nominees
  end
end
