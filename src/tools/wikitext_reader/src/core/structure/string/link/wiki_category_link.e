note
	description: "Summary description for {WIKI_CATEGORY_LINK}."
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_CATEGORY_LINK

inherit
	WIKI_LINK
		redefine
			process
		end

create
	make

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		do
			a_visitor.process_category_link (Current)
		end

end
