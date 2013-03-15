class Page < ActiveRecord::Base
  has_many :page_sections

  accepts_nested_attributes_for :page_sections

  default_scope order('order_number ASC')
  scope :active, where(active: true)

  validates_presence_of :title, :address 
  validates_uniqueness_of :address

  def to_param
    self.address
  end
end
