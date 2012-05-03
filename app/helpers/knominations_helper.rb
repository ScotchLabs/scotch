module KnominationsHelper
  def knomination_replace(content)
    content.scan(/@(\w+)/).each do |u|
      u = u.first
      
      if user = User.find_by_andrewid(u)
        content.sub!('@' + u, "#{link_to user.name, user}")
      end
    end
    
    content.html_safe
  end
end
