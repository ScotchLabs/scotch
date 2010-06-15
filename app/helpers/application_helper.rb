module ApplicationHelper
  def has_permission?(permName)
    current_user.has_global_permission(permName) ||
      (@group && @group.user_has_permission(current_user,permName))
  end
  def has_global_permission?(permName)
    current_user.has_global_permission(permName)
  end
end
