note
	description: "Summary description for {WIKI_RAW_STRING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_RAW_STRING

inherit
	WIKI_STRING_ITEM

create
	make

feature {NONE} -- Initialization

	make (s: STRING)
		do
			text := s
		end

feature -- Access

	text: STRING

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		do
			a_visitor.process_raw_string (Current)
		end

end
