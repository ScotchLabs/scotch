class AddSessionNameToEvents < ActiveRecord::Migration
  def change
    add_column :events, :session_name, :string

  end
end
