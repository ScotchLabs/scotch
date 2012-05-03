class CreateKudos < ActiveRecord::Migration
  def self.up
    create_table :kudos do |t|
      t.datetime :nominations_open
      t.datetime :start
      t.datetime :end
      t.datetime :woodscotch

      t.timestamps
    end
  end

  def self.down
    drop_table :kudos
  end
end
