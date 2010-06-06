class Position < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  belongs_to :group

  def to_s
    display_name
  end

end
