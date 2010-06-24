class ItemCategory < ActiveRecord::Base
  has_many :item_subcategories, :class_name => "ItemCategory"
  belongs_to :item_category, :foreign_key => :parent_id
  has_many :items
end
