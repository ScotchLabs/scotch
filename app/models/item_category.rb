class ItemCategory < ActiveRecord::Base
  has_many :item_subcategories, :class_name => "ItemCategory", :foreign_key => :parent_category_id
  belongs_to :parent_category, :class_name => "ItemCategory" # foreign key parent_category_id
  has_many :items
  
  validates_presence_of :parent_category, :unless => :parent_category_id.nil?
  validate :unique_slug
  
  def slug
    return nil if parent_category.nil?
    return parent_category.prefix+prefix
  end
  
protected
  def unique_slug
    errors.add(:prefix, "does not make a unique slug for this category") if ItemCategory.all.map {|ic| ic.slug }.compact.include? slug
  end
end
