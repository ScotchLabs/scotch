module ApplicationHelper
  def has_permission?(permName)
    current_user.has_global_permission?(permName) ||
      (@group && @group.user_has_permission?(current_user,permName))
  end
  def has_global_permission?(permName)
    current_user.has_global_permission?(permName)
  end

  def nav_class(link)
    if current_page? link then
      "class='navselected'"
    else
      ""
    end
  end

  #FIXME: These should print the time with different specificity depending on
  #how far in the future or past something is.  (e.g. if it is next week, just
  #print "May 20", but if it was last year print "May 20, 2010")
  def format_time(time)
    time.sprintf("%Y-%m-%d %H:%M")
  end
  def format_date(date)
    time.sprintf("%Y-%m-%d")
  end
end
