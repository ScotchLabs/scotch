class ItemCategory < ActiveRecord::Base
  has_many :item_subcategories
  has_many :items, :through => :item_subcategories
end
