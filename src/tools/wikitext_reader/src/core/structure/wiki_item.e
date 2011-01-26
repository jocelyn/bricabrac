note
	description: "Summary description for {WIKI_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	WIKI_ITEM

inherit
	WIKI_HELPER

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		require
			a_visitor_attached: a_visitor /= Void
		deferred
		end

end
