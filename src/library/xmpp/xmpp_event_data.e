note
	description: "Summary description for {XMPP_EVENT_DATA}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_EVENT_DATA

create
	make

feature {NONE} -- Initialization

	make (a_name: like name)
			-- Initialize xmpp event data with `a_name'
		do
			create variables.make (3)
			variables.compare_objects
			name := a_name
		end

feature -- Access

	name: STRING
			-- Name associated to an event

	variables: HASH_TABLE [STRING, STRING]
			-- Variables

	variable (n,d: STRING): STRING
			-- Value of variable named `n'
			-- return default value `d' if variable not found
		do
			if variables.has_key (n) then
				Result := variables.found_item
			else
				Result := d
			end
		end

	tag: XMPP_XML_TAG
			-- Associated XML tag

feature -- Element change

	set_name (v: like name)
			-- Set `name' to 'v'
		do
			name := v
		end

	add_variable (n,v: STRING)
			-- Add value `v' to variable named `n'
		do
			variables.force (v, n)
		end

	set_tag (v: like tag)
			-- Set associated tag `tag' to `v'
		do
			tag := v
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
