class ReportField < ActiveRecord::Base
  belongs_to :report_template

  default_scope order("field_order ASC")

  TYPES = [['Sub-Heading','subheading'],['Sub-Heading 2','subheading2'],
    ['Section Heading','sectionheading'],['Section Content','sectioncontent'],
    ['Tagged Text','taggedtext']]
end
