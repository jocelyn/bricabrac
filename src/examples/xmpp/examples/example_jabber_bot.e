note
	description: "Summary description for {EXAMPLE_JABBER_BOT}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	EXAMPLE_JABBER_BOT

inherit
	EXAMPLE_PARAMETERS

create
	make

feature {NONE} -- Initialization

	make
		do
			initialize_parameters
			execute
		end

feature -- Access

	execute
		local
			logger: XMPP_LOGGER
			retried: BOOLEAN
			l_data: XMPP_EVENT_DATA
			l_from: STRING
			l_send_is_xmpp_user: BOOLEAN
			l_type: STRING
			m,cmd: STRING
			l_vcard_request_to_remove: LINKED_LIST [STRING]
		do
			if not retried then
				create logger.make ({XMPP_LOGGER}.log_warning, (create {PLAIN_TEXT_FILE}.make_create_read_write ("jabber.log")))--) io.error)
--				create logger.make ({XMPP_LOGGER}.log_debug, io.error)
				create xmpp.make (host, 5222, user, password, "EiffelJabber", servername)

				xmpp.set_logger (logger)
				xmpp.auto_subscribe := True

				xmpp.connect (30, False, True)
				from
					create vcard_request.make (3)
				until
					xmpp.disconnected
				loop
					l_data := xmpp.process_until (<<"message", "presence", "end_stream", "session_start", "vcard">>, -1)
					if l_data /= Void then
						if {n: STRING} l_data.name then
							if n.is_case_insensitive_equal ("message") then
								l_from := l_data.variable ("from", "anonymous")
								l_send_is_xmpp_user := l_from.substring_index (xmpp.base_jid , 1) = 1
								l_type := l_data.variable ("type", Void)

								print ("---------------------------------------------%N")
								print ("Message from " + l_from)
								if l_type /= Void then
									print ("<type=" + l_type + ">")
								end
								if {subj: STRING} l_data.variable ("subject", Void) then
									print ("%T subject=%"" + subj + "%"")
								end
								print ("%N")

								m := l_data.variable ("body", "")
								if m = Void then
									m := ""
								end
								print (m)
								print ("%N---------------------------------------------%N")

								cmd := m.twin
								cmd.left_adjust
								if not cmd.is_empty and then cmd.item (1) = '#' then
									process_command (cmd.substring (2, cmd.count), l_data)
									if l_send_is_xmpp_user then
										if last_error = 0 then
											print ("Command [" + cmd + "] succeed.%N")
										else
											print ("Command [" + cmd + "] failed.%N")
										end
									elseif not xmpp.disconnected then
										if last_error = 0 then
											xmpp.message (l_from, "Command [" + cmd + "] succeed", l_type)
										else
											xmpp.message (l_from, "Command [" + cmd + "] failed", l_type)
										end
									end
								else
									if l_send_is_xmpp_user then
										print ("From XMPP's user [" + l_from + "]!!!%N")
									else
										xmpp.message (l_from, "Thanks for sending me the message [" + m + "]", l_type)
									end
								end
							elseif n.is_case_insensitive_equal ("presence") then
								print ("Presence: " + l_data.variable ("from", "???") + " [" + l_data.variable ("show","?") + "] " + l_data.variable ("status", "") + "%N")
--								xmpp.message (l_data.variable ("from", ""), "Hello, how are you today?", "chat")
							elseif n.is_case_insensitive_equal ("session_start") then
								print ("Session start%N")
								xmpp.get_roster
								xmpp.presence ("Cheese!")
							elseif n.is_case_insensitive_equal ("vcard") then
								print ("Vcard requested...%N")
								l_from := l_data.variable ("from", Void)
								if {vars: HASH_TABLE [STRING, STRING]} l_data.variables then
									from
										vars.start
										create m.make_empty
									until
										vars.after
									loop
										m.append_string (vars.key_for_iteration + ": " + vars.item_for_iteration + "%N")
										vars.forth
									end
								end
								from
									create l_vcard_request_to_remove.make
									vcard_request.start
								until
									vcard_request.after
								loop
									if l_from.is_case_insensitive_equal (vcard_request.item_for_iteration) then
										xmpp.message (l_from, "User %"" + vcard_request.key_for_iteration + "%" queried your vcard.", "chat")
										xmpp.message (vcard_request.key_for_iteration, m, "chat")
										l_vcard_request_to_remove.extend (vcard_request.key_for_iteration)
									end
									vcard_request.forth
								end
								if not l_vcard_request_to_remove.is_empty then
									l_vcard_request_to_remove.do_all (agent vcard_request.remove)
								end
							end
						end
					end
				end
			else
				print ("Exception .. bye bye%N")
			end
		rescue
			retried := True
			retry
		end

feature -- Properties

	xmpp: XMPP_PROTOCOL

	vcard_request: HASH_TABLE [STRING, STRING]

	last_error: INTEGER

	initialized: BOOLEAN
		do
			Result := xmpp /= Void
		end

feature -- Actions

	send_message (a_to: STRING; a_msg: STRING; a_data: XMPP_EVENT_DATA)
		local
		do

		end

	process_command (a_cmd: STRING; a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
		local
			s, op: STRING
			i,j: INTEGER
		do
			last_error := 0
			s := a_cmd.twin
			s.left_adjust
			i := s.index_of (' ', 1)
			j := s.index_of ('%T', 1)
			if j > 0 then
				i := i.min (j)
			end
			if i > 0 then
				op := s.substring (1, i - 1)
				s.remove_head (i)
				s.left_adjust
			else
				op := s.twin
				s.wipe_out
			end
			op.right_adjust

			if op.is_equal ("quit") then
				process_quit (a_data)
			elseif op.is_equal ("break") then
				process_break (a_data)
			elseif op.is_equal ("help") then
				process_help (a_data)
			elseif op.is_equal ("vcard") then
				process_vcard (a_data, s)
			elseif op.is_equal ("message") then
				process_message (a_data, s)
			else
				last_error := -1
			end
		end

	process_help (a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
			no_error: last_error = 0
		do
			xmpp.message (a_data.variable ("from", Void), "Usage: #quit, #break, #vcard {user}, #help", a_data.variable ("type", Void))
		end

	process_break (a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
			no_error: last_error = 0
		do
			xmpp.send ("</end>")
		end

	process_quit (a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
			no_error: last_error = 0
		do
			xmpp.disconnect
		end

	process_vcard (a_data: XMPP_EVENT_DATA; a_param: STRING)
		require
			initialized: initialized
			no_error: last_error = 0
		local
			l_from, par: STRING
		do
			par := a_param.twin
			par.left_adjust
			par.right_adjust
			l_from := a_data.variable ("from", xmpp.base_jid)
			if l_from /= Void and (par = Void or else par.is_empty) then
				par := l_from.twin
			end
			if par /= Void then
				if par.occurrences ('@') = 0 then
					par := par + "@" + xmpp.server
				end
				vcard_request.force (par, l_from)
				xmpp.get_vcard (par)
			else
				last_error := -1
			end
		end

	process_message (a_data: XMPP_EVENT_DATA; a_param: STRING)
		require
			initialized: initialized
			no_error: last_error = 0
		local
			i,j: INTEGER
			l_to, par: STRING
			msg: STRING
		do
			i := a_param.index_of (' ', 1)
			j := a_param.index_of ('%T', 1)
			if j > 0 then
				i := i.min (j)
			end
			if i > 0 then
				par := a_param.substring (1, i - 1)
				if i < a_param.count then
					msg := a_param.substring (i + 1, a_param.count)
				end
			else
				par := a_param.twin
			end
			if msg = Void then
				msg := ""
			end
			l_to := a_data.variable ("from", xmpp.full_jid)
			if par = Void or else par.is_empty then
				last_error := -1
			else
				if par.index_of ('@', 1) = 0 then
					par := par + "@" +  xmpp.server
				end
			end
			if last_error = 0 then
				xmpp.message (par, msg + " (sent by %"" + l_to + "%")", "chat")
			end
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
