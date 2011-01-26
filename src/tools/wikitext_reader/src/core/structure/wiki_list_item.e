note
	description: "Summary description for {WIKI_LIST_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_LIST_ITEM

inherit
	WIKI_LIST
		redefine
			debug_output,
			process
		end

create
	make_item

feature {NONE} -- Initialization

	make_item (a_description: STRING; s: STRING)
		do
			make (a_description)
			create text.make (s)
		end

feature -- Access

	text: WIKI_LINE -- STRING

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		do
			a_visitor.process_list_item (Current)
		end

feature -- Status report

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			Result := Precursor + " " + text.debug_output
		end

end
