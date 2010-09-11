class FixHairMakeupSlashProblem < ActiveRecord::Migration
  def self.up
    Position.where("display_name LIKE \"%//%\"").each do |p|
      puts "fixing #{p}"
      p.display_name = p.display_name.gsub("//","/")
      puts "    now #{p}"
      p.save!
    end
  end

  def self.down
  end
end
