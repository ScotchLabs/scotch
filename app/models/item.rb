class Item < Watchable
  has_many :checkouts

  belongs_to :item_category # foreign key item_category_id

  validates_presence_of :name, :item_category_id, :suffix
  validates_uniqueness_of :suffix, :scope => :item_category_id
  
  def catalog_number
    "%03d\-%03d" % [item_category.slug.to_i, suffix]
  end
  
  #TODO FIXME using these in lieu of scopes until I figure out how TODO that
  def self.available_items
    Item.all.select { |i| i.available? }
  end
  def self.unavailable_items
    Item.all.select {|i| !i.available? }
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
  
  # sort items by catalog number
  def <=>(other)
    catalog_number <=> other.catalog_number
  end
  
  def to_s
    "#{catalog_number} #{name}"
  end 
end
