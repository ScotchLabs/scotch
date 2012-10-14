class AddTechSkillsToUser < ActiveRecord::Migration
  def change
    add_column :users, :tech_skills, :string
  end
end
