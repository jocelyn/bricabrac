indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CUSTOMIZABLE_HORIZONTAL_SPLIT_AREA

inherit
	EV_HORIZONTAL_SPLIT_AREA
	
feature -- Not portable

	enable_flat_separator is
			-- 
		do
			implementation.enable_flat_separator			
		end

	disable_flat_separator is
			-- 
		do
			implementation.disable_flat_separator			
		end

end -- class CUSTOMIZABLE_HORIZONTAL_SPLIT_AREA