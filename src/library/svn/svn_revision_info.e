note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SVN_REVISION_INFO

inherit
	SVN_CONSTANTS
		export
			{NONE} all
		undefine
			is_equal
		end

	COMPARABLE

create
	make

feature

	make (r: INTEGER)
		do
			revision := r
			create {ARRAYED_LIST [TUPLE [path: STRING; kind: STRING; action: STRING]]} paths.make (5)
		end

feature -- Access

	revision: INTEGER

	author: STRING

	date: STRING

	paths: LIST [TUPLE [path: STRING; kind: STRING; action: STRING]]

	log_message: STRING

feature -- Status report

	is_less alias "<" (other: like Current): BOOLEAN
		do
			Result := revision < other.revision
		end

feature -- Element change

	set_revision (v: like revision)
		do
			revision := v
		end

	set_author (v: like author)
		do
			author := v
		end

	set_date (v: like date)
		do
			date := v
		end

	set_log_message (v: like log_message)
		do
			log_message := v
		end

	add_path (a_path: STRING; a_kind: STRING; a_action: STRING)
		do
			paths.force ([a_path, a_kind, a_action])
		end

note
	copyright: "Copyright (c) 2003-2010, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
