class Item < ActiveRecord::Base
  belongs_to :item_category # foreign key item_category_id

  validates_presence_of :name, :item_category_id
  validates_presence_of :item_category
  validates :catalog_number, :presence => true, :uniqueness => true, :format => {:with => /\d{3}\-\d{3}/}
  
  # virtual attribute. gives the end part of the catalog_number
  def suffix
    return @suffix unless @suffix.nil?
    self.catalog_number[4..6].to_i unless catalog_number.nil?
  end
  
  def suffix=(arg)
    @suffix = arg
    # if we've defined category we can go ahead and make the catalog_number
    create_catalog_number if self.suffix and self.item_category
  end
  
  def item_category_id=(arg)
    super
    # if we've defined the suffix we can go ahead and make the catalog_number
    create_catalog_number if self.suffix and self.item_category
  end
  
  def item_category=(arg)
    super
    # if we've defined the suffix we can go ahead and make the catalog_number
    create_catalog_number if self.suffix and self.item_category
  end
  
  # sort items by catalog number
  def <=>(other)
    catalog_number <=> other.catalog_number
  end
  
private

  def create_catalog_number
    self.catalog_number = "#{@item_category.slug}-%03d" % self.suffix
  end
    
end
