class ItemCategory < ActiveRecord::Base
  has_many :item_subcategories, :class_name => "ItemCategory", :foreign_key => :parent_category_id
  belongs_to :parent_category, :class_name => "ItemCategory" # foreign key parent_category_id
  has_many :items
  
  validates_presence_of :parent_category, :unless => :parent_category_id.nil?
  validates :prefix, :presence => true, :unique_slug => true
  
  def slug
    return nil if parent_category.nil?
    parent_category.prefix.to_s+prefix.to_s
  end
end
