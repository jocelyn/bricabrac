note
	description: "Summary description for {WIKI_MEDIA_LINK}."
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_MEDIA_LINK

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
			a_visitor.process_media_link (Current)
		end

end
