note
	description: "Summary description for {EXAMPLE_JABBER_BOT}."
	author: "Jocelyn Fiat (jfiat@eiffelsolution.com)"
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
			m,cmd: STRING
		do
			if not retried then
				create logger.make ({XMPP_LOGGER}.log_info, io.error)
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
								print ("---------------------------------------------%N")
								print ("Message from " + l_data.variable ("from", "???") + "%N")
								if {subj: STRING} l_data.variable ("subject", Void) then
									print ("Subject: " + subj + "%N")
								end
								m := l_data.variable ("body", "")
								if m = Void then
									m := ""
								end
								print (m)
								print ("---------------------------------------------%N")
								xmpp.message (l_data.variable ("from", Void), "Thanks for sending me the message [" + m + "]", l_data.variable ("type", Void))

								cmd := m.twin
								cmd.left_adjust
								if not cmd.is_empty and then cmd.item (1) = '#' then
									process_command (cmd.substring (2, cmd.count), l_data)
								end
							elseif n.is_case_insensitive_equal ("presence") then
								print ("Presence: " + l_data.variable ("from", "???") + " [" + l_data.variable ("show","?") + "] " + l_data.variable ("status", "") + "%N")
								xmpp.message (l_data.variable ("from", ""), "Hello, how are you today?", "chat")
							elseif n.is_case_insensitive_equal ("session_start") then
								print ("Session start%N")
								xmpp.get_roster
								xmpp.presence ("Cheese!")
							elseif n.is_case_insensitive_equal ("vcard") then
								print ("Vcard requested...%N")
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
									vcard_request.start
								until
									vcard_request.after
								loop
									xmpp.message (vcard_request.item_for_iteration, m, "chat")
									vcard_request.forth
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

	initialized: BOOLEAN
		do
			Result := xmpp /= Void
		end

feature -- Actions

	process_command (a_cmd: STRING; a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
		local
			s, op: STRING
			i,j: INTEGER
		do
			s := a_cmd.twin
			s.left_adjust
			i := s.index_of (' ', 1)
			j := s.index_of ('%T', 1)
			if j > 0 then
				i := i.min (j)
			end
			if i > 0 then
				op := s.substring (1, i - 1)
			else
				op := s.twin
			end
			op.right_adjust

			s.remove_head (i)
			s.left_adjust

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
			end
		end

	process_help (a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
		do
			xmpp.message (a_data.variable ("from", Void), "Usage: #quit, #break, #vcard {user}, #help", a_data.variable ("type", Void))
		end

	process_break (a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
		do
			xmpp.send ("</end>")
		end

	process_quit (a_data: XMPP_EVENT_DATA)
		require
			initialized: initialized
		do
			xmpp.disconnect
		end

	process_vcard (a_data: XMPP_EVENT_DATA; a_param: STRING)
		require
			initialized: initialized
		local
			par: STRING
		do
			par := a_param.twin
			par.left_adjust
			par.right_adjust
			if par = Void or else par.is_empty then
				par := xmpp.user + "@" +  xmpp.server
			end
			vcard_request.force (par, "from")
			xmpp.get_vcard (par)
		end

	process_message (a_data: XMPP_EVENT_DATA; a_param: STRING)
		require
			initialized: initialized
		local
			i,j: INTEGER
			par: STRING
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
			if par = Void or else par.is_empty then
				par := xmpp.user + "@" +  xmpp.server
			else
				if par.index_of ('@', 1) > 0 then
					xmpp.message (par, msg, "chat")
				else
					xmpp.message (par + "@" + xmpp.server, msg, "chat")
				end
			end
		end

end
