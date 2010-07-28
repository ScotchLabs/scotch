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
    title_tag = format[:title_tag]
    title_tag = "h1" unless format[:title_tag]
    message_tag = format[:message_tag]
    message_tag = "p" unless format[:message_tag]
    m = message
    m = "" unless m
    "<div id='#{anchor}'><#{title_tag}>#{name}</#{title_tag}><#{message_tag}>#{RedCloth.new(m).to_html}</#{message_tag}></div>"
  end
  # use this instead of the other if you're only using one HelpItem
  def block_full(format=Hash.new)
    "<div class='hidden'>#{block(format)}</div>"
  end
end
