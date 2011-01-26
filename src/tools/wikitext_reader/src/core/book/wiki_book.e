note
	description: "Summary description for {WIKI_BOOK}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_BOOK

inherit
	DEBUG_OUTPUT

create
	make

feature {NONE} -- Initialization

	make (n: STRING; p: like path)
		do
			name := n
			path := p
			create pages.make (50)
		end

feature -- Access

	path: STRING

	name: STRING

	pages: ARRAYED_LIST [WIKI_PAGE]

feature -- Element change

	add_page (a_page: WIKI_PAGE)
		do
			pages.extend (a_page)
		end

feature -- Status report

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			create Result.make_from_string (name)
			Result.append_character (':')
			Result.append_character (' ')
			Result.append_integer (pages.count)
			Result.append_string (" pages")
		end

end
