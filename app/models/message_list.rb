class MessageList < ActiveRecord::Base
  belongs_to :group
  has_many :recipients
  has_many :list_members
  has_many :users, through: :recipients

  validates_presence_of :name, :address, :security
  validates_uniqueness_of :address, scope: [:group_id]
  validates_inclusion_of :distribution, in: Message::DISTRIBUTION_TYPES

  after_commit :add_new_recipients
  after_commit :add_new_members

  attr_accessor :new_recipients, :new_members

  def recipients
    self.users
  end

  def recipients=(ids)
    ids = ids.split(',')
    self.new_recipients = []
    ids.each do |i|
      r = User.find_by_id(i)
      self.new_recipients << r if r
    end
  end

  def members
  end

  def members=(ids)
    ids = ids.split(',')
    self.new_members = []
    ids.each do |i|
      r = User.find_by_id(i)
      self.new_members << r if r
    end
  end

  protected

  def add_new_recipients
    unless self.new_recipients.nil?
      self.recipients.clear
      self.new_recipients.each do |r|
        recipient = Recipient.new
        recipient.user = r
        self.recipients << r
      end
    end
  end

  def add_new_members
    unless self.new_members.nil?
      self.list_members.clear
      self.new_members.each do |m|
        member = ListMember.new
        member.member = m
        self.list_members << member
      end
    end
  end
end
