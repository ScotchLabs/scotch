class Feedpost < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :user
  
  has_many :feedposts, :as => :parent, :dependent => :destroy

  # FIXME implement a feedpost _as_line_item and then uncomment this
  #define_index do
  #  indexes :headline
  #  indexes :body
  #end
  
  attr_protected :user_id, :parent_id, :parent_type
  
  POST_TYPES = [
    ['wall',"Wallpost"],
    ['comment',"Comment"]
  ]
  
  validates_presence_of :parent, :user, :headline
  validates_length_of :headline, :maximum => 140, 
    :message => "may not be more than 140 characters."
  validates_inclusion_of :post_type, :in => POST_TYPES.map{|e| e[0]}, 
    :message => "is not included in the list #{POST_TYPES.map{|e| e[0]}.inspect}"
  validates_inclusion_of :parent_type, :in => %w(Item Group User Feedpost)

  default_scope order("created_at DESC")
  scope :recent, limit(10)

  # from ActiveRecord:Associations:ClassMethods documentation.  Needed because
  # Groups uses STI.
  def parent_type=(sType)
    super(sType.to_s.classify.constantize.base_class.to_s)
  end

  def <=>(other)
    self.created_at <=> other.created_at
  end
end
