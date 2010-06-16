note
	description: "Summary description for {REPOSITORY_LOG_GROUP_FILTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REPOSITORY_LOG_GROUP_FILTER

inherit
	REPOSITORY_LOG_FILTER

create
	make

feature {NONE} -- Initialization

	make (n: INTEGER)
		do
			create filters.make (n)
		end

feature -- Access

	filters: ARRAYED_LIST [REPOSITORY_LOG_FILTER]

feature -- Element changes

	add_filter (f: REPOSITORY_LOG_FILTER)
		do
			filters.extend (f)
		end

feature -- Status report

	matched (a_log: REPOSITORY_LOG): BOOLEAN
		do
			from
				Result := True
				filters.start
			until
				filters.after or not Result
			loop
				Result := filters.item.matched (a_log)
				filters.forth
			end
		end

end
