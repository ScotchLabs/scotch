class Item < ActiveRecord::Base
  belongs_to :item_subcategory # foreign key item_subcategory_id
  # do we need to keep track of category too?

  validates_presence_of :item_subcategory, :name, :catalog_number
  validates_numericality_of :catalog_number
  validates_uniqueness_of :slug
  
  def slug
    "#{:item_subcategory.slug}-#{(:catalog_number.to_s.length < 3)? ("0"):("")}#{(:catalog_number.to_s.length < 2)? ("0"):("")}#{:catalog_number}"
  end
end
