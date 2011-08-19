# == Schema Information
#
# Table name: watchers
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  item_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  item_type  :string(255)
#

class Watcher < ActiveRecord::Base
  belongs_to :user

  belongs_to :item, :polymorphic => true
  belongs_to :watched_item, :class_name => "Item", :foreign_key => "item_id"
  belongs_to :watched_user, :class_name => "User", :foreign_key => "item_id"
  belongs_to :watched_group, :class_name => "Group", :foreign_key => "item_id"
  
  validates_presence_of :user, :item

  #FIXME ensure that each user/item pair is unique

  # from ActiveRecord:Associations:ClassMethods documentation.  Needed because
  # Groups uses STI.
  def item_type=(sType)
    super(sType.to_s.classify.constantize.base_class.to_s)
  end
end
