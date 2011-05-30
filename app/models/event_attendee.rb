class EventAttendee < ActiveRecord::Base
  #FIXME: do we need the kind column?

  belongs_to :user
  belongs_to :event

  validates_presence_of :event, :user

  validate :no_duplicates
  validate :no_past_changes

  def <=>(other)
    user <=> other.user
  end

  protected

  def no_duplicates
    if EventAttendee.where(:event_id => event.id, :user_id => user.id).where(["id != ?",id]).count > 0 then
      errors.add(:user, "is already attending this event")
    end
  end

  def no_past_changes
    if event.past?
      errors.add(:event, "has already occured")
    end
  end
end
