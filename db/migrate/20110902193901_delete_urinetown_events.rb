class DeleteUrinetownEvents < ActiveRecord::Migration
  def self.up
    if Show.exists?(:id => 48)
  	  g = Show.find 48
  	  e = g.events
  	  f = Feedpost.where(:parent_id => 48).where(:post_type => "create")

  	  f.destroy_all
  	  e.destroy_all
	  end

  end

  def self.down
  end
end
