class ReportValue < ActiveRecord::Base
  belongs_to :report
  belongs_to :report_field
end
