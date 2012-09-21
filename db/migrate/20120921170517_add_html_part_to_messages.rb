class AddHtmlPartToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :html_part, :text

  end
end
