class Report < ActiveRecord::Base
  belongs_to :report_template
  belongs_to :creator, class_name: 'User'
  belongs_to :document
  has_many :report_values

  accepts_nested_attributes_for :report_values
end
