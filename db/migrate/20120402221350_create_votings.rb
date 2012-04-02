class CreateVotings < ActiveRecord::Migration
  def self.up
    create_table :votings do |t|
      t.string :type
      t.string :name
      t.date :open_date
      t.date :close_date
      t.date :vote_date

      t.timestamps
    end
  end

  def self.down
    drop_table :votings
  end
end
