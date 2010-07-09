class Item < ActiveRecord::Base
  belongs_to :item_category # foreign key item_category_id

  validates_presence_of :name, :catalog_number
  validates_numericality_of :catalog_number
  validates :item_category_id, :object_exists => true
  validates :catalog_number, :unique_slug => true
  
  def slug
    return nil if item_category_id.nil?
    "#{item_category.slug}-%03d" % catalog_number
  end
end
