class HelpItem < ActiveRecord::Base
  validates :display_text, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :anchor, :presence => true, :uniqueness => true, :format => {:with => /^[a-zA-Z\-]*$/, :message => "may consist only of letters and hyphens"}
  validates :message, :presence => true
  
  # call this method from a view to retrieve a HelpItem
  # if the thing you're looking for doesn't exist it will error, so we don't
  # go into production with missing things
  def self.get(needle)
    self.find_by_name!(needle)
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
    title_tag = format[:title_tag] or "h1"
    message_tag = format[:message_tag] or "p"
    m = message or ""
    return "<div id='#{anchor}'><#{title_tag}>#{name}</#{title_tag}><#{message_tag}>#{RedCloth.new(m).to_html}</#{message_tag}></div>"
  end
end
