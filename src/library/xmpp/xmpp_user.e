note
	description: "Summary description for {XMPP_USER}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_USER

create
	make

feature {NONE} -- Initialization

	make (a_jid: like jid)
		require
			a_jid_attached: a_jid /= Void
		do
			jid := a_jid
			create groups.make
		end

feature -- Access

	jid: STRING assign set_jid
	name: STRING assign set_name
	subscription: STRING assign set_subscription
	groups: LINKED_LIST [STRING]

feature -- Change element

	set_jid (v: like jid)
		do
			jid := v
		end

	set_name (v: like name)
		do
			name := v
		end

	set_subscription (v: like subscription)
		do
			subscription := v
		end

	add_group (v: STRING)
		do
			groups.extend (v)
		end

note
	copyright: "Copyright (c) 2003-2008, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
