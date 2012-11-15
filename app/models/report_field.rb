class ReportField < ActiveRecord::Base
  belongs_to :report_template

  default_scope order("field_order ASC")

  scope :editable, where { field_type != 'sectionheading' }

  TYPES = [['Section Heading','sectionheading'],['Section Content','sectioncontent'],
    ['Tagged Text','taggedtext']]
end
