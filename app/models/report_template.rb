class ReportTemplate < ActiveRecord::Base
  has_many :report_fields

  accepts_nested_attributes_for :report_fields

  validates_inclusion_of :name, :sub_heading, :sub_heading2
end
