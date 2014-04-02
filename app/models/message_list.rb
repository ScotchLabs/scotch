class MessageList < ActiveRecord::Base
  belongs_to :group
  has_many :recipients, as: :owner

  attr_accessor :recipients_field

  validates_presence_of :name

  after_save :update_mailing_list

  def to
    "\"#{group.name} #{name}\"<#{group.short_name}+#{short_name}@sandbox14476fcd299e4b2499dabf21ce22f006.mailgun.org>"
  end

  def short_name
    name.gsub(' ', '').downcase
  end

  protected

  def update_mailing_list
    mg = Mailgunner::Client.new

    if name_changed?
      mg.delete_list("#{group.short_name}+#{name_was.gsub(' ', '').downcase}@sandbox14476fcd299e4b2499dabf21ce22f006.mailgun.org")

      mg.add_list({
        address: to,
        name: "#{group.name} #{name}"
      })
    end
  end
end
