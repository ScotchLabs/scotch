class Report < ActiveRecord::Base
  belongs_to :report_template
  belongs_to :creator, class_name: 'User'
  belongs_to :group
  belongs_to :folder
  has_many :report_values

  accepts_nested_attributes_for :report_values

  validates_presence_of :name, :report_template_id
end
