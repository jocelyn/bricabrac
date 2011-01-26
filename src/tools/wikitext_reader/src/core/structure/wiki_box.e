note
	description: "Summary description for {WIKI_BOX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	WIKI_BOX [G -> WIKI_ITEM]

inherit
	WIKI_COMPOSITE [G]

	WIKI_ITEM_WITH_PARENT [G]


--feature -- Visitor

--	process (a_visitor: WIKI_VISITOR)
--		do
--			a_visitor.process_box (Current)
--		end

end
