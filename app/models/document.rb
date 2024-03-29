# == Schema Information
#
# Table name: documents
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  group_id          :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer(4)
#  file_updated_at   :datetime
#  description       :text
#

class Document < ActiveRecord::Base
  # Coerce Paperclip into using custom storage
  include Shared::AttachmentHelper
  
  belongs_to :group
  belongs_to :folder

  attr_protected :group_id
  
  validates_presence_of :name

  acts_as_taggable

  # FIXME use :hash in the url when it works again
  has_attachment :file, :styles => { :thumb => ["50x50", :png] },
    :default_url => nil,
		:file_name => 'documents/:id_partition/:basename_:style.:extension'

  validates_attachment_presence :file

  validates_attachment_size :file, :less_than => 15.megabytes,
    :message => "must be less than 15 megabytes",
    :unless => lambda { |user| !user.file.nil? }

  def to_s
    name
  end

  before_file_post_process :image_file?

  def image_file?
    not ((file.content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif|pdf)$}).nil?)
  end
end
