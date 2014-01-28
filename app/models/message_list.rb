class MessageList < ActiveRecord::Base
  belongs_to :group
  has_many :recipients, as: :owner

  attr_accessor :recipients_field

  validates_presence_of :name

  def short_name
    name.gsub(' ', '').downcase
  end
end
