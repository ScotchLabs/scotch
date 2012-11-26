class Item < ActiveRecord::Base
  include Shared::AttachmentHelper

  CATEGORIES = [['Lighting/Electrics','electrics'],['Sound','sound'],['Costumes','costumes'],['Hair/Make-Up', 'hair'],
    ['Carpentry','carpentry'],['Tools','tools'],['Paint','paint'],['Props','props'],['Office Material','office'],
    ['Computing Equipment','computing']]

  TYPES = [['Normal','normal'],['Bucket/Box','bucket'],['Permanent','permanent']]

  belongs_to :area
  has_many :reservations
  has_many :allocations, through: :reservations

  has_attachment :picture, :styles => { :medium => ["300x300", :png], :thumb => ["50x50", :png] },
    :default_url => 'document_icon.png',
    :file_name => 'items/:id_partition/:basename_:style.:extension'

  validates_attachment_size :picture, :less_than => 15.megabytes,
    :message => "must be less than 15 megabytes",
    :unless => lambda { |item| !item.picture.nil? }

  validates_attachment_content_type :picture,
    :content_type => ["image/jpeg", "image/gif", "image/png"],
    :message => "must be an image (JPEG, GIF or PNG)",
    :unless => lambda { |item| !item.picture.nil? }  
end
