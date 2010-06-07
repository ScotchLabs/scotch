class Item < ActiveRecord::Base
  belongs_to :item_category

  validates_presence_of :item_category
end
