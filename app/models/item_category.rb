class ItemCategory < ActiveRecord::Base
  has_many :item_subcategories, :class_name => "ItemCategory", :foreign_key => :parent_category_id
  belongs_to :parent_category, :class_name => "ItemCategory" # foreign key parent_category_id
  has_many :items
  
  validates :parent_category_id, :object_exists => {:allow_nil => true, :allow_blank => true}
  validates :prefix, :presence => true, :numericality => true, :unique_slug => {:allow_nil => true, :allow_blank => true}
  
  scope :allParents, :conditions => {:parent_category_id => nil}, :order => "prefix ASC"
  
  def self.sorted
    self.allParents.map {|ic| [ic,ic.item_subcategories.sort {|x, y| x.slug<=>y.slug}]}.flatten
  end
  
  def self.groupedOptionsForSelect
    self.allParents.map{|p| ["#{p.prefix} #{p.name}", p.item_subcategories.map{|isc| ["#{isc.slug} #{isc.name}", isc.id]}]}
  end
  
  def slug
    return nil if parent_category.nil?
    "#{parent_category.prefix.to_s}%02d" % prefix.to_s
  end
end
