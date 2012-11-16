class ReportField < ActiveRecord::Base
  belongs_to :report_template

  default_scope order("field_order ASC")

  scope :editable, where { field_type != 'sectionheading' }

  TYPES = [['Section','section'], ['Tagged Text','taggedtext']]
end
