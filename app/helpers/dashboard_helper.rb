module DashboardHelper
  def event_to_json(event)
		# WTF Ruby is broken.
		# string.gsub("'", "\\'") duplicates all following non-whitespace
		def f(string) 
      string.gsub("'") { |c| "\\'" } 
    end
    return "{title : '[#{f event.group.short_name}] #{f event.title}', 
      start : '#{event.start_time.strftime("%Y-%m-%d")}', 
      end : '#{event.end_time.strftime("%Y-%m-%d")}',
      url : '#{event_url(event)}'}"
  end
end
