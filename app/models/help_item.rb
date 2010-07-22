class HelpItem < ActiveRecord::Base
  validates :display_text, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :anchor, :presence => true, :uniqueness => true, :format => {:with => /^[a-zA-Z\-]*$/, :message => "may consist only of letters and hyphens"}
  validates :message, :presence => true
  
  # call this method from a view to retrieve a HelpItem
  # if the thing you're looking for doesn't exist it won't
  # error because you'll get back an empty HelpItem
  def self.get(needle=nil)
    return HelpItem.new unless needle
    found = HelpItem.find_by_anchor(needle)
    return found unless found.nil?
    HelpItem.new
  end
  
  # call this from a view to fetch a lightwindow link for
  # this HelpItem
  # You can override the default display text with the argument
  def link(display=nil)
    display = display_text unless display
    "<a href='##{anchor}' class='lightwindow'>#{display}</a>"
  end
  
  # call this from a view to fetch a lightwindow inline element
  # for this HelpItem
  # You can override the default structure with format[:title_tag]
  # and format[:message_tag]
  def block(format=Hash.new)
    title_tag = format[:title_tag]
    title_tag = "h1" unless format[:title_tag]
    message_tag = format[:message_tag]
    message_tag = "p" unless format[:message_tag]
    m = message
    m = "" unless m
    "<div id='#{anchor}'><#{title_tag}>#{name}</#{title_tag}><#{message_tag}>#{RedCloth.new(m).to_html}</#{message_tag}></div>"
  end
end
