class AddSearchIndexesToUser < ActiveRecord::Migration
  def up
    execute "ALTER TABLE users ENGINE = MyISAM;"
    execute "CREATE FULLTEXT INDEX full_text_index_users ON users (andrewid, last_name, first_name);"
  end
end
