module UsersHelper
	def history_table
		def c(s) concat raw s end

		years = @user.active_years("Show")

		c "<script>function scrollHistory(index) {"
		c "	$('#history').animate({'right':index * 410});"
		c "}"
		c "function setBold(tag) {"
		c "	$('.historyYear').css({'font-weight':'normal'});"
		c "	$(tag).css({'font-weight':'bold'})"
		c "}</script>"
 
		c "<div style='text-align:center; width:410px; margin: 5px 0'>"
		#c "<div style='float:left'>&lt;</div><div style='float:right'>&gt;</div>"

		index = -1
		years.each { |year| 
			c "<span class='historyYear' style='margin: 0 10px; white-space: nowrap; cursor: pointer' onclick='scrollHistory(#{index += 1}); return setBold(this);'>"
			c "#{year.first.year} - #{year.last.year}"
			c "</span> " 
		}
		c "</div>"

		c "<script>var current = $('.historyYear'); setBold(current[current.length-1])</script>"

		c "<div style='width:100%; overflow:hidden; position:relative'>"
		c "<div style='position:relative; width: #{410*years.length}px; right: #{410*(years.length-1)}px' id='history'>"
		years.each { |year|

			show_positions = @user.positions_during(year, "Show")

			if show_positions.length > 0
				c "<div style='display: inline-block'>" 
				c "<h1>Production History</h1>"
				c "<table style='width:410px'><thead><tr><th style='width: 50%'>Show</th><th>Role</th></tr></thead>"
				grid = show_positions.inject({}) { |acc,pos|
					if acc[pos.group].nil?
						acc[pos.group] = [pos]
					else
						acc[pos.group] += [pos]
					end

					acc
				}

				odd = "#eee"
				(grid.sort_by { |k,v| k.archive_date }).each { |show,pos|
					positions = pos.map { |p| 
						if p.role.to_s == "Cast" 
							"<em>as " << p.to_s << "</em>"
						elsif p.role.to_s == "Tech Head" or p.role.to_s == "Production Staff"
							"<strong>" << p.to_s << "</strong>" 
						else 
							p.to_s 
						end 
					}
					positions = positions.join "<br/>"
					c "<tr style='background: #{odd}'><td style='padding:3px'>#{ link_to show.to_s, show_path(show) }</em></td><td style='padding:3px'>#{positions}</td></tr>"
					odd = odd == "#eee" ? "white" : "#eee"
				}
				c "</table>"
				c "</div>"
			end

			# TODO Someday, when we can track old board positions, etc, organizational
			# history will go here.

		}
		c "</div></div>"
	end

end
