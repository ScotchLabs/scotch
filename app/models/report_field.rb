class ReportField < ActiveRecord::Base
  require 'tag_parser'

  belongs_to :report_template

  default_scope order("field_order ASC")

  scope :editable, where { field_type != 'sectionheading' }

  TYPES = [['Section','section'], ['Tagged Text','taggedtext']]

  validates_presence_of :name

  def parsed_value(group)
    TagParser.parse_tags_for_group(self.default_value, group)
  end
end
