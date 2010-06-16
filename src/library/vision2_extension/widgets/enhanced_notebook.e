indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENHANCED_NOTEBOOK

inherit
	EV_NOTEBOOK

	EV_SHARED_APPLICATION
		undefine
			default_create, is_equal, copy
		end

create
	default_create

feature -- Access

	tooltip_behavior: EV_TOOLTIP_ON_WIDGET_BEHAVIOR

	set_tooltip_function (v: FUNCTION [ANY, TUPLE [like Current], STRING_GENERAL]) is
		do
			if v /= Void then
				if tooltip_behavior = Void then
					create tooltip_behavior.make (Current)
					inspect tab_position
					when tab_top then
						tooltip_behavior.set_offsets (10, 20)
					when tab_bottom then
						tooltip_behavior.set_offsets (10, -20)
					when tab_left then
						tooltip_behavior.set_offsets (20, 10)
					when tab_right then
						tooltip_behavior.set_offsets (-20, 10)
					else
						tooltip_behavior.set_offsets (10, -20)
					end
				end
				tooltip_behavior.set_tooltip_function (v)
			else
				if tooltip_behavior /= Void then
					tooltip_behavior := Void
				end
			end
		end

end
