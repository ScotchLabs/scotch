# == Schema Information
#
# Table name: feedposts
#
#  id            :integer(4)      not null, primary key
#  parent_id     :integer(4)
#  user_id       :integer(4)
#  post_type     :string(255)
#  headline      :string(255)
#  body          :text
#  created_at    :datetime
#  updated_at    :datetime
#  parent_type   :string(255)
#  privacy       :string(255)     default("All")
#  recipient_ids :text
#

class Feedpost < ActiveRecord::Base

  belongs_to :parent, :polymorphic => true
  belongs_to :reference, :polymorphic => true
  belongs_to :user
  
  has_many :feedposts, :as => :parent, :dependent => :destroy
  has_one :feedpost_attachment

  # FIXME implement a feedpost _as_line_item and then uncomment this
  #define_index do
  #  indexes :headline
  #  indexes :body
  #end
  
  before_validation :check_headline
  before_validation :check_privacy
  
  attr_protected :user_id
  
  POST_TYPES = [
    ['wall',"Wallpost"],
    ['comment',"Comment"],
    ['create',"Creation"]
  ]
  
  validates_presence_of :parent, :user, :headline
  validates_length_of :headline, :maximum => 140, 
    :message => "may not be more than 140 characters."
  validates_inclusion_of :post_type, :in => POST_TYPES.map{|e| e[0]}, 
    :message => "is not included in the list #{POST_TYPES.map{|e| e[0]}.inspect}"
  validates_inclusion_of :parent_type, :in => %w(Item Group User Feedpost Nomination)

  PRIVACY_OPTIONS = %w(Hidden Recipients Group All)

  serialize :recipient_ids, Array
  validates_inclusion_of :privacy, :in => PRIVACY_OPTIONS

  default_scope order("created_at DESC")
  scope :recent, limit(10)
  scope :after, lambda { |feedpost| where(:parent_id => feedpost.parent_id).where(:parent_type => feedpost.parent_type).where(["feedposts.id < ?",feedpost.id])}
  
  # from ActiveRecord:Associations:ClassMethods documentation.  Needed because
  # Groups uses STI.
  def parent_type=(sType)
    super(sType.to_s.classify.constantize.base_class.to_s)
  end

  def <=>(other)
    self.created_at <=> other.created_at
  end

  def can_access?(member)

    return true if privacy == "All"

    Raise "There is a problem with this feedpost." if not parent.kind_of? Group

    return true if member.superuser? or parent.user_is_superuser?(member)

    case privacy
    when "Hidden"
      false
    when "Recipients"
      not recipient_ids.nil? and recipient_ids.include?(member.id)
    when "Group"
      member.member_of?(parent)
    else
      raise "There is a problem with this feedpost."
    end
  end

  def document_id=(id)
    id = id.to_i
    return if id.nil? or id == 0
    attachment = self.build_feedpost_attachment
    attachment.document_id = id
  end
  
private
  def check_headline
    self.headline = self.body.split(' ').slice(0,5).join(' ')+'...' if self.headline.nil? or self.headline.blank?
  end
  
  def check_privacy
    if parent.kind_of? Group then
      PRIVACY_OPTIONS.include? privacy
    else
      privacy == "All"
    end
  end
end
