note
	description: "[
			Summary description for {WIKI_TABLE}.
			
			{| border="1" cellspacing="0" cellpadding="5" align="center"
			! This
			! is
			|- 
			| a
			| table
			|}
			
			renders
			
			This    |   is               (first row in bold)
			-----------------
			a       | table

		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_TABLE

inherit
	WIKI_BOX [WIKI_TABLE_ROW]
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
			a_visitor.process_table (Current)
		end

end
