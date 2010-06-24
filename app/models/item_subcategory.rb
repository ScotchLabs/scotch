class ItemSubcategory < ActiveRecord::Base
  belongs_to :item_category # foreign key item_category_id
  has_many :items
  
  validates_presence_of :item_category, :infix
  validates_numericality_of :infix
  validates_uniqueness_of :slug
  
  def slug
    "#{:item_category.prefix}#{(:infix.to_s.length < 2)? ("0"):("")}#{:infix}"
  end
end
