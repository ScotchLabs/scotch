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
    flav = [
      "Scotch'n'Soda's Online Informatory",
      "Have you seen the new Dungeon?",
      "Unofficially sponsored by Jolt Cola",
      "Is informatory even a word?",
      "It seemed like a good idea at the time",
      "Eh, we'll do it later"
    ]
    flav[rand(flav.length)]
  end
end
