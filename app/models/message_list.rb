class MessageList < ActiveRecord::Base
  belongs_to :group
  has_many :recipients, as: :owner

  attr_accessor :recipients_field

  validates_presence_of :name

  after_save :update_mailing_list, if: :name_changed?
  after_save :update_recipients

  def to
    "\"#{group.name} #{name}\"<#{mail_address}>"
  end

  def mail_address
    "#{group.short_name}+#{name.gsub(' ', '').downcase}@#{ENV['MAILGUN_DOMAIN']}"
  end

  def short_name
    name.gsub(' ', '').downcase
  end

  def update_mailing_list
    mg = Mailgunner::Client.new

    mg.delete_list("#{group.short_name}+#{name_was.gsub(' ', '').downcase}@#{ENV['MAILGUN_DOMAIN']}")

    mg.add_list({
      address: mail_address,
      name: "#{group.name} #{name}"
    })

    update_recipients
  end

  def update_recipients
    mg = Mailgunner::Client.new

    recipients.each do |r|
      mg.add_list_member(address, {
        address: r.mail_address
      })
    end
  end

  def delete_mailing_list
    mg = Mailgunner::Client.new

    mg.delete_list(mail_address)
  end
end
