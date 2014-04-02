class Contact < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :protocol, :address
  validates_uniqueness_of :address, scope: :protocol

  def name
    self.user.try(:name) || self.temporary_name || self.email
  end

  def email
    self.protocol == 'email' ? self.address : nil
  end

  def to
    "\"#{name}\"<#{email}>"
  end

  def phone_number
    self.protocol == 'phone' ? self.address : nil
  end
end
