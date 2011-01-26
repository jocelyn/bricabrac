note
	description: "Summary description for {WIKI_BOXED_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_BOXED_ITEM

inherit
	WIKI_BOX [WIKI_ITEM]

create
	make

feature {NONE} -- Initialization

	make (a_item: WIKI_ITEM)
		do
			initialize
			add_element (a_item)
		end

invariant

	single_item: count = 1

end
