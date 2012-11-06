class ReportTemplate < ActiveRecord::Base
  has_many :report_fields

  accepts_nested_attributes_for :report_fields
end
