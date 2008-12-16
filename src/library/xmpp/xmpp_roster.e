note
	description: "Summary description for {XMPP_ROASTER}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_ROSTER

create
	make

feature {NONE} -- Initialization

	make
			-- Create Current Roster
		do
			create contacts.make (5)
		end

feature -- Access

	contacts: ARRAYED_LIST [XMPP_USER]
			-- List of contacts contained in Current Roster

feature -- Element change

	add_contact (c: XMPP_USER)
			-- Add contact to Current
		do
			contacts.force (c)
		end

	set_presence (a_from, a_priority, a_show, a_status: STRING)
			-- Set presence for user associated to `a_from'
		do
			--| Not Yet Implemented
		end

note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.net/
		]"
end
