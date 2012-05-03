class CreateKnominations < ActiveRecord::Migration
  def self.up
    create_table :knominations do |t|
      t.string :content

      t.timestamps
    end
  end

  def self.down
    drop_table :knominations
  end
end
