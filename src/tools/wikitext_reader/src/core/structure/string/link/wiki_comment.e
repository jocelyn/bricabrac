note
	description: "Summary description for {WIKI_COMMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_COMMENT

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
			a_visitor.process_comment (Current)
		end

end
