# == Schema Information
#
# Table name: help_items
#
#  id           :integer(4)      not null, primary key
#  display_text :string(255)
#  name         :string(255)
#  anchor       :string(255)
#  message      :text
#  created_at   :datetime
#  updated_at   :datetime
#

include HelpItemsHelper
class HelpItem < ActiveRecord::Base
  validates :display_text, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :anchor, :presence => true, :uniqueness => true, :format => {:with => /^[a-zA-Z\-]*$/, :message => "may consist only of letters and hyphens"}
  
  # call this method from a view to retrieve a HelpItem
  # if the thing you're looking for doesn't exist it will error, so we don't
  # go into production with missing things
  def self.get(needle)
    self.find_by_anchor!(needle)
  end
  
  # call this from a view to get the full package:
  # anchor, full script, and full block
  def full(display=nil, params=Hash.new, format=Hash.new)
    "#{link(display)}#{script_full(params)}#{block_full(format)}"
  end
  
  # call this from a view to fetch a lightwindow link for
  # this HelpItem
  # You can override the default display text with the argument
  def link(display=nil)
    display = display_text unless display
    getLinkHtml(anchor, display)
  end
  
  # call this from a view to set up the linking script between
  # he anchor element and the block element
  def script_full(params=Hash.new)
    getScriptCall(anchor, params, true)
  end
  # use this instead of the full version if you're going to be
  # using several HelpItems
  def script(params=Hash.new)
    getScriptCall(anchor, params)
  end
  
  # call this from a view to fetch a lightwindow inline element
  # for this HelpItem
  # You can override the default structure with format[:title_tag]
  # and format[:message_tag]
  def block(format=Hash.new)
    getDivBlock(anchor, name, format)
  end
  # use this instead of the other if you're only using one HelpItem
  def block_full(format=Hash.new)
    getDivBlock(anchor,name,format,true)
  end
end
