module ApplicationHelper
  extend ActiveSupport::Memoizable

  def has_permission?(permName)
    perm = Permission.fetch(permName)
    current_user.has_global_permission?(perm) ||
      (@group && @group.user_has_permission?(current_user,perm))
  end
  def has_global_permission?(permName)
    perm = Permission.fetch(permName)
    current_user.has_global_permission?(perm)
  end

  memoize :has_permission?
  memoize :has_global_permission?

  #TODO FIXME this is too specific. I'll deal with it later.
  def nav_class(link)
    if current_page? link then
      "navselected"
    else
      ""
    end
  end

  #FIXME: These should print the time with different specificity depending on
  #how far in the future or past something is.  (e.g. if it is next week, just
  #print "May 20", but if it was last year print "May 20, 2010")
  def format_time(time)
		if time.nil?
			"-"
		else
    	time.strftime("%I:%M %p on %B %d, %Y")
		end
  end
  def format_date(date)
		if date.nil?
			"-"
		else
    	date.strftime("%B %d, %Y")
		end
  end
  
  def flavortext
    # The first flavortext in this list is the only one used until the person
    # logs in, then it cycles pseudo-randomly
    flav = [
      "Scotch'n'Soda's Online Informatory",
      "Is Informatory Even A Word?",
      "Breaking Legs and Taking Names Since 1938",
      "Enabling Dangerous Acts Since 1938",
      "Loving Every Minute Of It Since 1938",
      "Conscripting Baggers Since 1938",
      "Pretentious since 1938",
      "Have you seen the new Dungeon?",
      "Unofficially sponsored by Jolt Cola",
      "It seemed like a good idea at the time",
      "No, we will *not* implement an S'n'Cest feature!",
      "The Mafia of Theatre",
      "Proud to be Fierce!",
      "SSTH FTW",
      "<Show Name Here> BITES",
      "Anyone want to steal the fence?",
      "Powered By Kitten Sneezes",
      "Better Than 6 Hours of Sex and Bacon",
      "Because Academics Come First",
      "This message brought to you by Spackle For President",
      "Have you finished your budget yet?",
      "Who are we kidding, it's really \"Scotchbook\"",
      "Like Facebook, but not for losers",
      "We took Facebook and changed the Stylesheet",
      "Don't stick it in the crazy",
      "You are beautiful",
      "You are loved and appreciated",
      "You don't suck",
      "Sunshine, puppies, and fresh-baked cookies",
      "10 points for brushing your teeth every day",
      "Caitlin thinks you're attractive",
      "Too close for missiles, switching to guns" # if you remember facebook in 2005 you will keep this one
    ]
    if current_user
      flav[rand(flav.length)]
    else
      flav[0]
    end
  end
  
  # so help me if we ever have more than one person in a "Webmaster" Position
  def current_webmaster
    p = Group.system_group.positions.where(:display_name => "Webmaster").first
    u = p ? p.user : nil
    # heaven forbid we ever have no webmaster
    if u.nil?
      u = User.new
      u.first_name = "the"
      u.last_name = "webmaster"
      u.email = "webmaster@snstheatre.org"
    end
    u
  end
  
  def textilize_without_paragraph(text) 
    return nil if text.nil?
    textiled = textilize(text)
    if textiled[0..2] == "<p>" then textiled = textiled[3..-1] end
    if textiled[-4..-1] == "</p>" then textiled = textiled[0..-5] end
    return textiled
  end

  def as_icon(object, options)
    return nil if object.nil?
    return case object.class.name
    when "User" then user_as_icon(object, options)
    when "Group" then group_as_icon(object, options)
    when "Show" then group_as_icon(object, options)
    when "Board" then group_as_icon(object, options)
    else ""
    end
end

  def user_as_icon(user, options)
    pass = Hash.new
    if options.nil? or options[:text].nil?
      pass[:text] = user
    else
      pass[:text] = options[:text]
    end
    pass[:image] = image_tag user.headshot(:thumb)
    pass[:href] = url_for(user) if options.nil? or options[:link].nil? or options[:link] != false
    object_as_icon(pass)
  end

  def group_as_icon(group, options)
    pass = Hash.new
    if options.nil? or options[:text].nil?
      pass[:text] = group
    else
      pass[:text] = options[:text]
    end
    pass[:image] = image_tag group.image(:thumb)
    pass[:href] = url_for(group) if options.nil? or options[:link].nil? or options[:link] != false
    object_as_icon(pass)
  end
  
  def object_as_icon(options)
    href = ''
    link = true
    if options.nil? or options[:href].nil?
      link = false
    else
      href = options[:href]
    end
    text = ''
    text = options[:text] if options and options[:text]
    image = ''
    image = options[:image] if options and options[:image]
    
    c = ''
    c = "#{c}<a href='#{href}'>" if link
    c = "#{c}<div class='icon'>#{image}" if image
    c = "#{c}<div>#{text}</div>" if text
    c = "#{c}</div>" if image
    c = "#{c}</a>" if link
    c
  end
end
