class ItemCategory < ActiveRecord::Base
  # All ICs with "parent_category_id" == this id are subcategories of this
  # when we destroy this, we destroy them too.
  has_many :item_subcategories, :class_name => "ItemCategory", :foreign_key => :parent_category_id, :dependent => :destroy
  # Note that calling parent_category only works when this has a parent_category_id
  belongs_to :parent_category, :class_name => "ItemCategory" # foreign key parent_category_id
  # All items with "item_category_id" == this id are items of this
  # when we destroy this, we destroy items
  has_many :items, :dependent => :destroy
  
  validate :parent_category_exists
  validates :prefix, :presence => true, :numericality => true, :unique_slug => {:allow_nil => true, :allow_blank => true}
  
  # this scope selects categories that don't have parents. they are the top-level parents
  scope :parent_categories, where(:parent_category_id => nil).order("prefix ASC")
  
  def <=>(other)
    # compare two top-level
    if slug.nil? and other.slug.nil?
      return prefix <=> other.prefix
      
    # compare this top-level and other second-level
    elsif slug.nil?
      # if other is inside this, it's below this
      return -1 if other.parent_category_id == id
      
      # else compare top-levels
      return prefix <=> other.parent_category.prefix unless other.parent_category_id == id
      
    # compare this second-level and other top-level
    elsif other.slug.nil?
      # if this is inside other, it's below other
      return 1 if parent_category_id == other.id
      
      # else compare top-levels
      return parent_category.prefix <=> other.prefix unless parent_category_id == other.id
      
    # compare two second-level
    else
      # if in the same top-level compare slugs
      return slug <=> other.slug if parent_category_id == other.parent_category_id
      
      # else compare parents
      return parent_category.prefix <=> other.parent_category.prefix unless  parent_category_id == other.parent_category_id
    end
  end
  
  # useful for creating selects with optgroups of the top-level categories and options of the second-level categories
  def self.groupedOptionsForSelect
    self.parent_categories.map{|p| ["#{p.prefix} #{p.name}", p.item_subcategories.map{|isc| ["#{isc.slug} #{isc.name}", isc.id]}]}
  end
  
  def slug
    return nil if parent_category.nil?
    "#{parent_category.prefix.to_s}%02d" % prefix.to_s
  end
  
protected

  def parent_category_exists
    return if parent_category_id.nil? or parent_category_id.blank?
    begin
      ItemCategory.find(parent_category_id)
    rescue RecordNotFound
      errors[parent_category_id] << "does not correspond to a valid Item Category"
    end
  end
  
end
