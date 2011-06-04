class Document < ActiveRecord::Base
  # Coerce Paperclip into using custom storage
	include Shared::AttachmentHelper
  
  belongs_to :group

  attr_protected :group_id

  validates_presence_of :group_id
  validates_presence_of :name

  acts_as_taggable

  # FIXME use :hash in the url when it works again
  has_attachment :file,
    :default_url => nil,
		:file_name => 'documents/:id_partition/:basename:extension'

  validates_attachment_size :file, :less_than => 15.megabytes,
    :message => "must be less than 15 megabytes",
    :unless => lambda { |user| !user.file.nil? }
end
