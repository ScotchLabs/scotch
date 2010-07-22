class Item < ActiveRecord::Base
  belongs_to :item_category # foreign key item_category_id
  has_many :checkouts

  validates_presence_of :name, :item_category_id
  validates_presence_of :item_category
  validates :catalog_number, :presence => true, :uniqueness => true, :format => {:with => /\d{3}\-\d{3}/}
  
  #TODO FIXME using these in lieu of scopes until I figure out how TODO that
  def self.available_items
    Item.all.map{|i| ((i.available?)? (i):(nil))}.compact
  end
  def self.unavailable_items
    Item.all.map{|i| ((!i.available?)? (i):(nil))}.compact
  end
  
  # some item names are super long
  def shortname
    name[0..27]+((name.length>30)? ("..."):(""))
  end
  
  # returns true if item is ready to be checked out
  def available?
    current_checkout.nil?
  end
  
  def current_checkout
    checkouts.each do |c|
      return c if c.open?
    end
    nil
  end
  
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
  
  def to_s
    "#{catalog_number} #{name}"
  end
  
private

  def create_catalog_number
    self.catalog_number = "#{@item_category.slug}-%03d" % self.suffix
  end
    
end
