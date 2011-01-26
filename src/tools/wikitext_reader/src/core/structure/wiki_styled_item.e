note
	description: "Summary description for {WIKI_STYLED_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_STYLED_ITEM

inherit
	WIKI_BOX [WIKI_ITEM]

create
	make,
	make_strike

feature {NONE} -- Initialization

	make
		do
			initialize
		end

	make_strike
		do
			make
		end

end
