note
	description: "[
			Summary description for {WIKI_TABLE_ROW}.

		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_TABLE_ROW

inherit
	WIKI_COMPOSITE [WIKI_TABLE_CELL]
		redefine
			process
		end

create
	make

feature {NONE} -- Initialization

	make
		do
			initialize
		end

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		do
			a_visitor.process_table_row (Current)
		end

end
