# == Schema Information
#
# Table name: items
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  location         :string(255)
#  description      :text
#  item_category_id :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  catalog_number   :string(255)
#

class Item < Shared::Watchable
  has_many :checkouts
  has_many :past_checkouts, :class_name => "Checkout", :conditions => "checkin_date IS NOT NULL", :order => "created_at DESC"
  has_one :current_checkout, :class_name => "Checkout",  :conditions => "checkin_date IS NULL", :order => "created_at DESC"

  belongs_to :item_category # foreign key item_category_id

  validates_presence_of :name, :item_category_id, :catalog_number
  validates_uniqueness_of :catalog_number

  before_validation :generate_catalog_number, :on => :create

  attr_accessor :suffix

  scope :outstanding, joins(:current_checkout)

  define_index do
    indexes :name
    indexes :location
    indexes :description
    indexes :catalog_number
  end
  
  # some item names are super long
  def shortname
    name[0..27]+((name.length>30)? ("..."):(""))
  end
  
  # returns true if item is ready to be checked out
  def available?
    current_checkout.nil?
  end
  
  # sort items by catalog number
  def <=>(other)
    catalog_number <=> other.catalog_number
  end
  
  def to_s
    "#{catalog_number} #{name}"
  end

  protected 

  def generate_catalog_number
    if self.suffix.nil? or self.suffix.blank?
      prefix = "%03d" % self.item_category.slug.to_i
      last_item = Item.where(["catalog_number LIKE ?", "#{prefix}-%"]).order("catalog_number DESC").first
      unless last_item.nil?
        self.suffix = last_item.catalog_number[4..6].to_i + 1
      else
        self.suffix = 1
      end
    end

    self.catalog_number = "%03d\-%03d" % [self.item_category.slug.to_i, self.suffix]
  end
end
