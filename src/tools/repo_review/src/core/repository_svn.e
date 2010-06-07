note
	description: "Summary description for {REPOSITORY_SVN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REPOSITORY_SVN

inherit
	REPOSITORY
		redefine
			make
		end

create
	make,
	make_with_location

feature {NONE} -- Initialization

	make
		do
			create location.make_empty
			Precursor
			create engine
		end

	make_with_location (a_loc: like location)
		do
			make
			set_location (a_loc)
		end

feature -- Access

	location: STRING

	info: detachable SVN_REPOSITORY_INFO
		do
			Result := engine.repository_info (location)
		end

	statuses (is_verbose, is_recursive, is_remote: BOOLEAN): detachable LIST [SVN_STATUS_INFO]
		do
			Result := engine.statuses (location, is_verbose, is_recursive, is_remote)
		end

	logs (is_verbose: BOOLEAN; a_start, a_end: INTEGER; a_limit: INTEGER): detachable LIST [SVN_REVISION_INFO]
		do
			Result := engine.logs (location, is_verbose, a_start, a_end, a_limit)
		end

feature -- Element change

	set_location (v: like location)
		require
			v_attached: v /= Void
		do
			location := v
		ensure
			location_set: v ~ location
		end

feature -- Implementation

	engine: SVN_ENGINE

end
