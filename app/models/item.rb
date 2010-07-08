class Item < ActiveRecord::Base
  belongs_to :item_category # foreign key item_category_id

  validates_presence_of :item_category, :name, :catalog_number
  validates_numericality_of :catalog_number
  validates :catalog_number, :unique_slug => true
  
  def slug
    "#{:item_category.slug}-#{(:catalog_number.to_s.length < 3)? ("0"):("")}#{(:catalog_number.to_s.length < 2)? ("0"):("")}#{:catalog_number}"
  end
end
