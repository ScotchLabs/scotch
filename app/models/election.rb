# == Schema Information
#
# Table name: elections
#
# id                :integer(4)
# name              :string(255)
# position          :string(255)
# platform          :text
#


class Election < ActiveRecord::Base
  
  validates_presence_of :name, :position, :platform
  POSITIONS = ["President", "Vice President", "Artistic Director", "Managing Director", "Technical Coordinator", "Secretary", "Public Relations Coordinator", "General Membership Coordinator", "Rights & Reservations Representative"]

  #belongs_to :id

  define_index do
    indexes :name
    indexes :position
    indexes :platform
  end

  def to_s
    name
  end
end
