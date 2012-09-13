class ListMember < ActiveRecord::Base
  belongs_to :message_list
  belongs_to :member, polymorphic: true
end
