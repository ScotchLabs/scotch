class Item < ActiveRecord::Base
  belongs_to :item_category # foreign key item_category_id

  validates_presence_of :name, :item_category_id
  validates_presence_of :item_category
  validates :catalog_number, :presence => true, :numericality => true, :unique_slug => {:allow_nil => true, :allow_blank => true}
  
  def <=>(other)
    slug <=> other.slug
  end
  
  def slug
    return nil if item_category_id.nil?
    return nil unless item_category.respond_to? "slug"
    "#{item_category.slug}-%03d" % catalog_number
  end
end
