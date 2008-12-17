note
	description: "Summary description for {EXAMPLE_SEND_MESSAGE}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	EXAMPLE_SEND_MESSAGE

inherit
	EXAMPLE_PARAMETERS

create
	make

feature -- Access

	make
		do
			initialize_parameters
			send (
					user, password, servername, host, port,
					"jfiat", <<"Hello, this is a message sent using EiffelJabber">>,
					create {XMPP_LOGGER}.make ({XMPP_LOGGER}.log_info, io.error)
				)
		end

	send (a_user, a_pass: STRING; a_servername, a_host: STRING; a_port: INTEGER;
			a_to_user: STRING; a_mesgs: ARRAY [STRING]; a_log: XMPP_LOGGER)
		local
			xmpp: XMPP_PROTOCOL
			l_data: XMPP_EVENT_DATA
			l_to_user: STRING
		do
			l_to_user := a_to_user.twin
			if l_to_user.occurrences ('@') = 0 then
				l_to_user.append ("@" + a_servername)
			end
			create xmpp.make (a_host, a_port, a_user, a_pass, "EiffelJabber", a_servername)
			xmpp.set_logger (a_log)
			xmpp.connect (30, False, True)
			l_data := xmpp.process_until (<<"session_start">>, -1)
			xmpp.presence_with_details (Void, "available", Void, "available", 0)
			a_mesgs.do_all (agent (x: XMPP_PROTOCOL; u: STRING; s: STRING)
					do
						x.message (u, s, "chat")
					end(xmpp, l_to_user, ?)
				)
			xmpp.disconnect
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
