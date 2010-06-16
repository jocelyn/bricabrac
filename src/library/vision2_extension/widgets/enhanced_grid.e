indexing
	description: "Objects that represents a GRID containing Object values (for debugging)"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENHANCED_GRID

inherit
	ES_GRID

create
	default_create

feature

	expand_all is
		local
			r: INTEGER
			l_row: EV_GRID_ROW
		do
			if row_count > 0 then
				from
					r := 1
				until
					r > row_count
				loop
					l_row := row (r)
					if l_row.is_expandable then
						l_row.expand
					end
					r := r + 1
				end
			end
		end

end
