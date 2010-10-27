class AddSitewideNotice < ActiveRecord::Migration
  def self.up
    h = HelpItem.create(:name => "Sitewide Notice", :anchor => "sitewide-notice",
                    :display_text => "Sitewide Notice", :message => "")
    h.save!
  end

  def self.down
  end
end
