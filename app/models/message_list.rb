class MessageList < ActiveRecord::Base
  require 'letter_opener' if Rails.env.development?
  belongs_to :group
  has_many :recipients
  has_many :list_members
  has_many :users, through: :recipients
  has_many :messages

  validates_presence_of :name, :address, :security
  validates_uniqueness_of :address, scope: [:group_id]
  validates_inclusion_of :distribution, in: Message::DISTRIBUTION_TYPES

  after_commit :add_new_recipients
  after_commit :add_new_members

  attr_accessor :new_recipients, :new_members

  def self.error_reply(to, message)
    mail = Mail.new
    mail.from = "errors@snstheatre.org"
    mail.to = to
    mail.subject = "[Scotch] Message Error"
    mail.body = "You're last message generated an error: \r\n\r\n #{message}"

    mail.delivery_method LetterOpener::DeliveryMethod, location: File.join(File.dirname(__FILE__), '/../', 'tmp', 'letter_opener') if Rails.env.development? 
    mail.deliver
  end

  def can_post?(user)
    if security == 'anyone'
      true
    elsif security == 'recipients'
      self.users.include? user
    elsif security == 'members'
      self.members.include? user
    end
  end

  def recipients
    self.users
  end

  def recipient_list
    self.users.map do |user|
      {id: user.id, name: user.name}
    end
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
    User.where(id: self.list_members.pluck('member_id'))
  end

  def member_list
    self.members.map do |member|
      {id: member.id, name: member.name}
    end
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
