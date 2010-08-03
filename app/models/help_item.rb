class HelpItem < ActiveRecord::Base
  validates :display_text, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :anchor, :presence => true, :uniqueness => true, :format => {:with => /^[a-zA-Z\-]*$/, :message => "may consist only of letters and hyphens"}
  validates :message, :presence => true
  
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
    "<a href='#' id='colorbox-#{anchor}'>#{display}</a>"
  end
  
  # call this from a view to set up the linking script between
  # he anchor element and the block element
  def script_full(params=Hash.new)
    "<script>$(document).ready(function(){#{script(params)}})</script>"
  end
  # use this instead of the full version if you're going to be
  # using several HelpItems
  def script(params=Hash.new)
    # defaults
    p = Hash.new
    p[:inline] = true
    p[:href] = "\"##{anchor}\""
    p[:opacity] = 0.25
    p[:transition] = '"none"'
    p[:width] = '"50%"'
    
    # override defaults / add params
    params.each do |k, v|
      p[k] = v
    end
    
    # turn into string
    t = ""
    p.each do |k, v|
      t << "#{k}: #{v}, "
    end
    t = t[0...-2]
    
    "$(\"#colorbox-#{anchor}\").colorbox({#{t}})"
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
  # use this instead of the other if you're only using one HelpItem
  def block_full(format=Hash.new)
    "<div class='hidden'>#{block(format)}</div>"
  end
end
