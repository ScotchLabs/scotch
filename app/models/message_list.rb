class MessageList < ActiveRecord::Base
  belongs_to :group
  has_many :recipients
  has_many :list_members
  has_many :users, through: :recipients

  validates_presence_of :name, :address, :security
  validates_uniqueness_of :address, scope: [:group_id]
  validates_inclusion_of :distribution, in: Message::DISTRIBUTION_TYPES

  def recipients
    self.users
  end

  def recipients=(ids)
  end

  def members
  end

  def members=(ids)
  end
end
