indexing
	description : "eiffel_jabber application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			ex_msg: EXAMPLE_SEND_MESSAGE
			ex_bot: EXAMPLE_JABBER_BOT
		do
			create ex_msg.make
			create ex_bot.make
--			test_with_http_protocol
--			test_send_messages_with_xmpp_protocol
--			test_with_socket
		end

	test_send_messages_with_xmpp_protocol
		local
			m: ARRAY [STRING]
			tc: THREAD_CONTROL
			wt: WORKER_THREAD
			i: INTEGER
			mut: MUTEX
			logger: XMPP_LOGGER_MT
		do
			m :=	<<
						"This is a test message #1",
						"This is a test message #2",
						"This is a test message #3"
					>>

			from
				create mut.make
				create logger.make ({XMPP_LOGGER}.log_error, io.error)
				logger.set_mutex (mut)
				i := 1
			until
				i >= 10
			loop
				create wt.make (agent xmpp_protocol_send_message ("webbot", "webb0t123", "jabber.ise", "jabber.ise", 5222,	"jfiat@jabber.ise", <<"Send message thread id#" + i.out>>, logger))
--				create wt.make (agent xmpp_protocol_send_message ("web", "web", "websites.lan", "websites.lan", 5222,	"jfiat@websites.lan", <<"Send message thread id#" + i.out>>, logger))
				logger.log ("launching thread ...", 0)
				wt.launch
				logger.log ("Thread #" + i.out + " launched", {XMPP_LOGGER}.log_info)
				sleep (500_000_000 )

				i := i + 1
			end
--			xmpp_protocol_send_message ("f.jocelyn", "ahmerde", "gmail.com", "talk.google.com", 5222, "f.jocelyn@gmail.com", m)
--			xmpp_protocol_send_message ("web", "web", "websites.lan", "websites.lan", 5222,	"jfiat@websites.lan", m)
--			xmpp_protocol_send_message ("jfiat", "jfiat", "jabber.ise", "jabber.ise", 5222,	"jfiat@jabber.ise", m)

			create tc
			tc.join_all
			print ("thread done%N")
		end

	xmpp_protocol_send_message (a_user, a_pass: STRING; a_servername, a_host: STRING; a_port: INTEGER;
			a_to_user: STRING; a_mesgs: ARRAY [STRING]; a_log: XMPP_LOGGER)
		local
			xmpp: XMPP_PROTOCOL
			a: ANY
		do
--			create xmpp.make ("talk.google.com", 5222, "f.jocelyn", "ahmerde", "eiffel_jabber", "gmail.com")
--			create xmpp.make ("websites.lan", 5222, "web", "web", "eiffel_jabber", "websites.lan")
			create xmpp.make (a_host, a_port, a_user, a_pass, "eiffel_jabber", a_servername)
			xmpp.set_logger (a_log)
			xmpp.connect (30, False, True)
			a := xmpp.process_until (<<"session_start">>, -1)
			xmpp.presence_with_details (Void, "available", Void, "available", 0)
			a_mesgs.do_all (agent (x: XMPP_PROTOCOL; u: STRING; s: STRING)
					do
						x.message (u, s + " (to:" + u + ")", Void)
					end(xmpp, a_to_user, ?)
				)
			xmpp.disconnect
			print ("XMPP message sent!%N")
		end

--	test_with_http_protocol
--		local
--			http: HTTP_PROTOCOL
--			url: HTTP_URL
--		do
--			create url.make ("http://websites.lan/www/index.html")
--			create http.make (url)
--			http.set_read_mode
--			http.set_port (80)
--			http.set_timeout (100)
--			http.open
--			http.initiate_transfer
--			if not http.error then
--				http.read
--				if not http.error then
--					print (http.last_packet)
--				end
--			end
--			http.close
--		end

	test_with_socket
		local
			localhost, remotehost: HOST_ADDRESS
			socket: NETWORK_STREAM_SOCKET
			response: STRING
			c: STRING
		do
			--| Add your code here
			create localhost.make_local
			create remotehost.make_from_name ("websites.lan")
			create socket.make_client_by_port (5222, "websites.lan")
			socket.connect
			if socket.is_open_write then
				c := ""
				c.append ("<?xml version='1.0'?>%N")
				c.append ("<stream:stream")
				c.append (" to=%"websites.lan%"")
				c.append (" xmlns:stream=%"http://etherx.jabber.org/streams%"")
				c.append (" xmlns=%"jabber:client%"")
				c.append (" version=%"1.0%">")
				c.append ("</stream:stream>")
				socket.put_string (c)
			end
			if socket.is_open_read then
				socket.read_character
				if socket.last_character /= '%U' then
					from
						response := ""
					until
						socket.last_character = '%U' or response.substring_index ("</stream:stream>", 1) > 0
					loop
						response.append_character (socket.last_character)
						socket.read_character
					end
				end
			end
			if socket.is_open_write then
				c := "<starttls xmlns=%"urn:ietf:params:xml:ns:xmpp-tls%"/>"
				socket.put_string (c)
			end
			if socket.is_open_read then
				socket.read_character
				if socket.last_character /= '%U' then
					from
						response := ""
					until
						socket.last_character = '%U' or response.substring_index ("/>", 1) > 0
					loop
						response.append_character (socket.last_character)
						socket.read_character
					end
				end
			end
			if socket.is_open_write then
				c := ""
--				c.append ("<?xml version='1.0'?>%N")
				c.append ("<stream:stream")
				c.append (" to=%"websites.lan%"")
				c.append (" xmlns:stream=%"http://etherx.jabber.org/streams%"")
				c.append (" xmlns=%"jabber:client%"")
				c.append (" version=%"1.0%">")
				c.append ("</stream:stream>")
				socket.put_string (c)
			end
			if socket.is_open_read then
				socket.read_character
				if socket.last_character /= '%U' then
					from
						response := ""
					until
						socket.last_character = '%U' or response.substring_index ("</stream:stream>", 1) > 0
					loop
						response.append_character (socket.last_character)
						socket.read_character
					end
				end
			end


			socket.cleanup
		end

end
