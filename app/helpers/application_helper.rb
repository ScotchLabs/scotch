module ApplicationHelper
  def has_permission?(permName)
    perm = Permission.fetch(permName)
    current_user.has_global_permission?(perm) ||
      (@group && @group.user_has_permission?(current_user,perm))
  end
  def has_global_permission?(permName)
    perm = Permission.fetch(permName)
    current_user.has_global_permission?(perm)
  end

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
    time.strftime("%Y-%m-%d %H:%M")
  end
  def format_date(date)
    date.strftime("%Y-%m-%d")
  end
  
  def flavortext
    # The first flavortext in this list is the only one used until the person
    # logs in, then it cycles pseudo-randomly
    flav = [
      "Scotch'n'Soda's Online Informatory",
      "Breaking Legs and Taking Names Since 1938",
      "Have you seen the new Dungeon?",
      "Unofficially sponsored by Jolt Cola",
      "It seemed like a good idea at the time",
      "Enabling Dangerous Acts Since 1938",
      "No, we will *not* implement an S'n'Cest feature!",
      "Where good decisions go to die"
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
  
  # This is for use with the user's autocomplete view
  # It finds the user that corresponds to the identifier
  # currently the identifier we use is
  # FIRST LAST EMAIL
  def retreive_user(identifier)
    return nil if identifier.nil? or identifier.blank?
    return nil if identifier.split(" ").length != 3
    email = identifier.split(" ")[2]
    User.find_by_email(email)
  end
  
  def filter_referrals(text)
    return if text.nil? or text.blank?
    
    # the first/most prevalent syntax should be
    # "#{obj.class.to_s}##{obj.id}"
    # we don't want to use object_id since it's not findable
    typeRegex = /Checkout|Document|User|Group|Event|HelpItem|Item/
    matches = text.scan(/#{typeRegex}\#[\d]+/)
    matches.each do |match|
      puts "REFERRAL MATCH: #{match}"
      classname = match[0...match.index('#')]
      id = match[match.index('#')+1..-1]
      
      begin
        objclass = Kernel.const_get classname
      rescue NameError
        # ignore thing that doesn't match
        # since we can't find it to validate
        next
      end
      
      obj = objclass.find(id)
      # ignore thing we can't find
      # since we can't find it to validate
      next if obj.nil?
      
      # this part assumes that all REFERRABLE classes
      # implement a smarter "to_s" than Object's
      text.gsub!(match, link_to(obj.to_s, obj))
    end
    
    raw(text)
  end
end
