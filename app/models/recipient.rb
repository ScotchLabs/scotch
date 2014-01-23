class Recipient < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :group
  belongs_to :target, polymorphic: true

  def to
    if target.is_a? User
      target.email
    else
      if group
        "#{group.short_name}@snstheatre.org"
        return "#{group.short_name}+#{target.short_name}@snstheatre.org" if target
        return "#{group.short_name}+#{target_identifier.downcase.gsub(' ', '')}@snstheatre.org" if target_identifier
      else
        return "#{target.short_name}@snstheatre.org" if target
        return "#{target_identifier.downcase.gsub(' ', '')}@snstheatre.org" if target_identifier
      end
    end
  end

  def subject
    prefix = '['

    if target.is_a? User
      prefix += 'Scotch'
    else
      if group
        prefix += group.short_name.capitalize + ' '

        if target
          prefix += target.name
        elsif target_identifier
          prefix += target_identifier
        end
      else
        if target
          prefix += target.name
        elsif target_identifier
          prefix += target_identifier
        end
      end
    end

    prefix + '] ' + owner.subject
  end

  def envelope_recipients
    if target_identifier
      if group
        Position.where(group_id: group.id, display_name: target_identifier)
        .includes(:user).map { |p| p.user.email }
      else
        Position.where(group_id: Group.active, display_name: target_identifier)
        .includes(:user).map { |p| p.user.email }
      end
    elsif target.is_a? User
      [target.email]
    elsif target.is_a? Group
      target.members.pluck(:email)
    elsif target.is_a? Role
      if group
        Position.where(group_id: group, role_id: target)
        .includes(:user).map { |p| p.user.email }
      else
        Position.where(group_id: Group.active, role_id: target)
        .includes(:user).map { |p| p.user.email }
      end
    end
  end
end
