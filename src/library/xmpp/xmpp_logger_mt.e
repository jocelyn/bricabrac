note
	description: "Summary description for {XMPP_LOGGER_MT}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_LOGGER_MT

inherit
	XMPP_LOGGER
		redefine
			log
		end

create
	make

feature -- Access

	mutex: MUTEX
			-- Mutex

feature -- Element change

	set_mutex (v: like mutex)
			-- Set `mutex' to `v'
		do
			mutex := v
		end

feature -- Basic operation

	log (msg: STRING; a_lev: INTEGER)
			-- <Precursor>
			-- using `mutex' for concurrency reason
		local
			mut: like mutex
		do
			mut := mutex
			if mut /= Void then
				mut.lock
			end
			Precursor {XMPP_LOGGER} (msg, a_lev)
			if mut /= Void then
				mut.unlock
			end
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
