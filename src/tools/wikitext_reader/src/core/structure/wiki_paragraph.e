note
	description: "Summary description for {WIKI_PARAGRAPH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_PARAGRAPH

inherit
	WIKI_BOX [WIKI_ITEM]
		redefine
			process,
			valid_element
		end

create
	make

feature {NONE} -- Initialization

	make
		do
			initialize
		end

feature -- Status report

	valid_element (e: WIKI_ITEM): BOOLEAN
		do
			Result := attached {WIKI_LINE} e
		end

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		do
			a_visitor.process_paragraph (Current)
		end

end
