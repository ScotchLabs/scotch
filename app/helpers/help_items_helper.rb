module HelpItemsHelper
  def getLinkHtml(anchor, display)
    "<a href='#' id='colorbox-#{anchor}'>#{display}</a>"
  end

  def getScriptCall(anchor, params=Hash.new, full=false)
    t = ""
    t = "" if full
    
    # defaults
    p = Hash.new
    p[:href] = "\"##{anchor}\""
    p[:width] = '"25%"'
    
    # override defaults / add params
    params.each do |k, v|
      p[k] = v
    end
    
    # turn into string
    paramstring = ""
    p.each do |k, v|
      paramstring << "#{k}: #{v}, "
    end
    paramstring = paramstring[0...-2]
    
    script = "$(\"#colorbox-#{anchor}\").colorbox({#{paramstring}})"
    
    if full
      "<script>$(document).ready(function(){#{script}});</script>"
    else
      "$(document).ready(function(){#{script}});"
    end
  end
  
  def getDivBlock(anchor, name, format=Hash.new, full=false)
    title_tag = (format[:title_tag] or "h1")
    message_tag = (format[:message_tag] or "p")
    m = (message or "")
    
    t = ""
    t = "<div class='hidden'>" if full
    t = "#{t}<div id='#{anchor}'><#{title_tag}>#{name}</#{title_tag}><#{message_tag}>#{RedCloth.new(m).to_html}</#{message_tag}></div>"
    t = "#{t}</div>" if full
    t
  end
end
