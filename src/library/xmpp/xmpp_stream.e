note
	description: "Summary description for {XMPP_STREAM}."
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
	XMPP_STREAM

inherit
	ANY

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		end

	EXCEPTIONS
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialization

	make (a_host: like host; a_port: like port; a_is_server: like is_server)
			-- Create Current Stream with host, port values.
		do
			-- Initialize values
			packet_size := 1024
			xml_depth := 0
			disconnected := False
			send_disconnect := False
			reconnect := True
			been_reset := False
			use_ssl := False
			reconnect_timeout := 5
			last_id := 0
			stream_start := "<stream>"
			stream_end := "</stream>"
			create until_event_names.make (5)
			until_event_names.compare_objects

			create until_count.make (5)
			create until_event_data.make (5)

			create id_handlers.make (5)
			create xpath_handlers.make (10)
			create event_handlers.make (10)

			-- Parameters
			host := a_host
			port := a_port
			is_server := a_is_server
			reconnect := not a_is_server
			initialize_parser
		end

	initialize_parser
			-- Initialize XMP parser
		local
			l_parser: XM_EIFFEL_PARSER
			l_callbacks: XMPP_XML_PARSER
		do
			create l_parser.make
			l_parser.set_string_mode_latin1
--			l_parser.set_string_mode_unicode
			create l_callbacks.make
			l_parser.set_callbacks (l_callbacks)
			l_callbacks.set_xml_agents (agent start_xml, agent end_xml)
			parser := l_parser
		ensure
			parser_attached: parser /= Void
		end

	reset
			-- Reset current stream
		do
			xml_depth := 0
			if {p: like parser}	parser then
				p.reset
			end
			if not is_server then
				send (stream_start)
			end
			been_reset := True
		end

feature -- Logging

	logger: XMPP_LOGGER
			-- Logger engine

	set_logger (a_log: like logger)
			-- Set `logger' to `a_log'
		do
			logger := a_log
		end

	log (m: STRING; lev: INTEGER)
			-- Log message `m' for log level `lev'
		do
			if {l: like logger} logger then
				l.log (m, lev)
			end
		end

feature -- Destroying

	destroy
			-- Destroy current stream
		do
			if disconnected and socket /= Void then
				disconnect
			end
		end

feature -- Access

	host: STRING
			-- Server's host

	port: INTEGER
			-- Server's port

	disconnected: BOOLEAN
			-- Is disconnected

	send_disconnect: BOOLEAN
			-- Send disconnect?

	reconnect: BOOLEAN
			-- Reconnect if dropped?

	been_reset: BOOLEAN
			-- Connection was resetted

	is_server: BOOLEAN
			-- Is server type

	default_ns: STRING
			-- Default Namespace

	use_ssl: BOOLEAN

	reconnect_timeout: INTEGER assign set_reconnect_timeout

feature {NONE} -- Implementation

	socket: NETWORK_STREAM_SOCKET

	packet_size: INTEGER
			-- Read socket by amount of `packet_size' bytes

	parser: XM_EIFFEL_PARSER

	buffer: STRING

	xml_depth: INTEGER

	last_id: INTEGER
			-- Last id

	stream_start: STRING
			-- XML Stream message: start

	stream_end: STRING
			-- XML Stream message: end	

	until_event_names: ARRAYED_LIST [ARRAY [STRING]]
	until_count: HASH_TABLE [INTEGER, INTEGER]
	until_event_data: HASH_TABLE [XMPP_EVENT_DATA, INTEGER]

--	last_send: REAL
--	protected $ns_map = array();
--	protected $current_ns = array();
--	protected $nshandlers = array();
--	protected $until_happened = false;


feature -- Access: handlers

	xpath_handlers: ARRAYED_LIST [TUPLE [cases: LIST [TUPLE [path: STRING; name: STRING]]; hdl: like xpath_handler]]

	id_handlers: HASH_TABLE [like id_handler, STRING]

	event_handlers: ARRAYED_LIST [TUPLE [name: STRING; hdl: like event_handler]]

feature -- Element change

	get_id: STRING
			-- Get an `id'
		do
			last_id := last_id + 1
			Result := last_id.out
		end

	set_use_ssl (b: like use_ssl)
			-- Set `use_ssl' to `b'
		do
			use_ssl := b
		end

	set_reconnect_timeout (v: like reconnect_timeout)
			-- Set `reconnect_timeout' to `v'
		do
			reconnect_timeout := v
		end

	set_packet_size (v: like packet_size)
			-- Set `packet_size' to `v'
		do
			packet_size := v
		end

feature -- Element change: handler

	add_id_handler (a_id: STRING; a_hdl: like id_handler)
			-- Add id handler `a_hdl'
		do
			id_handlers.force (a_hdl, a_id)
		end

	add_xpath_handler (a_xpath: STRING; a_hdl: like xpath_handler)
			-- Add xpath handler `a_hdl'
		local
			l_xpath_array: ARRAYED_LIST [TUPLE [path: STRING; name: STRING]]
			r: RX_PCRE_REGULAR_EXPRESSION
			ns_tags: ARRAY [STRING]
			t: STRING
			i, p: INTEGER
		do
			r := xpath_regular_expression
			r.match (a_xpath)
			if r.has_matched  then
				create ns_tags.make (1, r.match_count)
				from
					i := 1
				until
					i > r.match_count
				loop
					ns_tags[i] := r.captured_substring (i - 1)
					i := i + 1
				end
			else
				ns_tags := <<a_xpath>>
			end

			create l_xpath_array.make (ns_tags.count)
			from
				i := ns_tags.lower
			until
				i > ns_tags.upper
			loop
				t := ns_tags.item (i)
				p := t.index_of ('}', 1)
				if p > 0 then
					l_xpath_array.force ([t.substring (2, p - 1), t.substring (p + 1, t.count)])
				else
					l_xpath_array.force ([Void, t])
				end
				i := i + 1
			end
			xpath_handlers.force ([l_xpath_array, a_hdl])
		end

	add_event_hander (a_name: STRING; a_hdl: like event_handler)
			-- Add event handler `a_hdl'
		do
			event_handlers.force ([a_name, a_hdl])
		end

feature {NONE} -- Implementation: handler

	xpath_regular_expression: RX_PCRE_REGULAR_EXPRESSION
		once
			create Result.make
			Result.set_caseless (True)
			Result.compile ("\(?{[^\}]+}\)?(\/?)[^\/]+")
		ensure
			Result_compiled: Result /= Void and then Result.is_compiled
		end

	id_handler (a_d: like get_id): PROCEDURE [ANY, TUPLE [ANY]]
		do
		end

	event_handler: PROCEDURE [ANY, TUPLE [like event_handler_argument_type]]
		do
		end

	event_handler_argument_type: XMPP_EVENT_DATA
		do
		end

	xpath_handler: PROCEDURE [ANY, TUPLE [XMPP_XML_TAG]]
		do
		end

feature -- Basic operation

	event (a_name: STRING; a_event_data: like event_handler_argument_type)
			-- Notify event `a_name'
		require
			a_event_data_attached: a_event_data /= Void
		local
			t: TUPLE [name: STRING; hdl: like event_handler]
			k: INTEGER
			i: INTEGER
			b: BOOLEAN
		do
			log ("[Event] " + a_name, {XMPP_LOGGER}.log_info)
			if {evt_hdls: like event_handlers} event_handlers then
				from
					evt_hdls.start
				until
					evt_hdls.after
				loop
					t := evt_hdls.item
					if a_name.is_equal (t.name) then
						t.hdl.call([a_event_data])
					end
					evt_hdls.forth
				end
			end
			if {until_lst: like until_event_names} until_event_names then
				from
					until_lst.start
				until
					until_lst.after
				loop
					if {arr: ARRAY [STRING]} until_lst.item then
						from
							i := arr.lower
						until
							i > arr.upper or b
						loop
							b := arr[i].is_case_insensitive_equal (a_name)
							i := i + 1
						end
						if b then
							k := until_lst.index
							a_event_data.set_name (a_name) -- FIXME
							until_event_data.force (a_event_data, k)
							if until_count.has_key (k) then
								until_count.force (until_count.found_item + 1, k)
							else
								until_count.force (1, k)
							end
						end
					end
					until_lst.forth
				end
			end
		end


	send (m: STRING)
			-- Send packet `m'
		local
			l_reconnect: BOOLEAN
			err: INTEGER
		do
			log ("SEND[" + m + "]", {XMPP_LOGGER}.log_debug)
			if {s: like socket} socket then
				if s.is_open_write then
					err := internal_send_string (s, m)
					if err /= 0 then
						l_reconnect := True
					end
				else
					l_reconnect := True
				end
			else
				l_reconnect := True
			end
			if l_reconnect then
				do_reconnect
			end
		end

	connect (a_timeout: INTEGER; a_persistent: BOOLEAN; a_sendinit: BOOLEAN)
			-- Connect the xmpp server
		local
			start_time: like time
			s: NETWORK_STREAM_SOCKET
			l_continue: BOOLEAN
--			conflag: INTEGER
--			l_conntype: STRING
		do
			log ("[Connect] timeout=" + a_timeout.out + " sendinit=" + a_sendinit.out, {XMPP_LOGGER}.log_verbose)
			send_disconnect := False
			start_time := time
			from
				l_continue := True
			until
				not l_continue
			loop
				disconnected := False
				send_disconnect := False
				if use_ssl then
					check not_yet_implemented: False end
				end

--				if a_persistent then
--					conflag := STREAM_CLIENT_CONNECT | STREAM_CLIENT_PERSISTENT
--				else
--					conflag := STREAM_CLIENT_CONNECT
--				end
--				l_conntype := "tcp"
--				if use_ssl then
--					l_conntype := "ssl"
--					check False end
--				end
				s := socket
				if s = Void or else not s.exists then
					create s.make_client_by_port (port, host)
--					s.set_reuse_address
				end
				s.set_timeout (a_timeout)

				log ("[Connect] connecting tcp://" + host + ":" + port.out, {XMPP_LOGGER}.log_verbose)
				s.connect
				if s.connection_refused or s.not_connected then
					log ("[Connect] connection failed", {XMPP_LOGGER}.log_error)
					raise_xmpp_exception (s.error)
					s.cleanup
					s := Void
				end

				if s = Void or else not s.exists then
					disconnected := True
					s.cleanup
					s := Void
					log ("[Sleep] " + a_timeout.out + " seconds", {XMPP_LOGGER}.log_verbose)
					sleep (a_timeout.min (5) * 1_000_000_000)
				end
				l_continue := s = Void and then time - start_time < a_timeout
			end

			if s /= Void and then s.exists then
				socket := s
				s.set_blocking
				if a_sendinit then
					send (stream_start)
				end
			else
				raise_xmpp_exception ("Could not connect before timeout.")
			end
		end

	do_reconnect
		do
			if not is_server then
				log ("[Reconnect] ...", {XMPP_LOGGER}.log_debug)
				connect (reconnect_timeout, False, False)
				reset
				event (event_name_reconnect, Void)
			end
		end

	disconnect
		local
			a: ANY
		do
			if socket /= Void and then socket.exists then
				reconnect := False
				send (stream_end)
				send_disconnect := True
				a := process_until (<<event_name_end_stream>>, 5)
				disconnected := True
			end
		end

	process
			-- Process
		local
			b: BOOLEAN
		do
			b := internal_process (0)
		end

	process_time (a_timeout: INTEGER)
			-- Process until a timeout occurs
		local
			b: BOOLEAN
		do
			if a_timeout = 0 then
				b := internal_process (0)
			else
				b := internal_process (a_timeout * 1_000_000)
			end
		end

	process_until (a_events: ARRAY [STRING]; a_timeout: INTEGER): XMPP_EVENT_DATA
			-- Process until a specified event or a timeout occurs	
		local
			start: like time
			event_key: INTEGER
			l_event_data: XMPP_EVENT_DATA
			l_continue: BOOLEAN
		do
			log ("[process_until] timeout=" + a_timeout.out + " ...", {XMPP_LOGGER}.log_verbose)
			a_events.do_all (agent (s: STRING)
				do
					log ("[process_until] ->" + s, {XMPP_LOGGER}.log_verbose)
				end)

			start := time
			until_event_names.force (a_events)
			until_event_names.finish
			event_key := until_event_names.index
			until_event_names.start

			until_count.force (0, event_key)
--			$updated = '';
			from
				l_continue := True
			until
				not l_continue
			loop
--				log ("start=" + start.out + " time=" + time.out + " timeout=" + a_timeout.out, {XMPP_LOGGER}.log_debug)
				process
				l_continue := not disconnected and
					 until_count.item (event_key) < 1 and
					 (time - start < a_timeout or a_timeout = -1)
			end
			if {upl: like until_event_data} until_event_data and then upl.has_key (event_key) then
				l_event_data := upl.found_item
				until_event_data.remove (event_key)
				until_count.remove (event_key)
				until_event_names.go_i_th (event_key); until_event_names.remove
			else
				l_event_data := Void -- create {like l_event_data}.make
			end
			Result := l_event_data
		end


feature {NONE} -- Implementation: Execution

	internal_process (maximum: INTEGER): BOOLEAN
		local
			remaining: like time_point
			l_continue: BOOLEAN
			start_time, end_time, time_past: like time_point
			s: like socket
			msg: STRING
			l_secs: INTEGER
			old_timeout: INTEGER
			b: INTEGER
		do
			remaining := maximum
			from
				l_continue := True
				s := socket
			until
				not l_continue
			loop
				start_time := time_point
--				$read = array($this->socket);
--				$write = array();
--				$except = array();
				l_secs := 1
--				if maximum = -1 then
--					l_usecs := - 1
--					l_secs := -1
--				elseif maximum = 0 then
--					l_secs := 0
--					l_usecs := 0
--				else
--					l_usecs := remaining \\ 1_000_000
--					l_sec := (remaining - l_usecs) // 1_000_000
--				end
				old_timeout := s.timeout
				s.set_timeout (l_secs)
				b := safe_ready_for_reading (s)
				s.set_timeout (old_timeout)
				if b = 1 then
					msg := internal_read (s)
					if msg /= Void then
						process_xml (msg)
					else
						if reconnect then
							do_reconnect
						else
							s.cleanup
							l_continue := False
						end
					end
				elseif b = 0 then

				else
					log ("Error when trying to read socket", {XMPP_LOGGER}.log_error)
					if not s.is_open_read then
						if reconnect then
							do_reconnect
						else
							s.cleanup
							l_continue := False
						end
					end
				end
				end_time := time_point
				time_past := end_time - start_time;
				remaining := remaining - time_past
				l_continue := l_continue and ((s /= Void and then s.exists) and (maximum = -1 or remaining > 0))
				log ("internal_process: maximum=" + maximum.out + " remaining=" + remaining.out
						+ " start_time=" + start_time.out
						+ " end_time=" + end_time.out
						+ " continue=" + l_continue.out
						, {XMPP_LOGGER}.log_debug)
			end
		end

	internal_send_string (s: like socket; msg: STRING): INTEGER
		local
			retried: BOOLEAN
		do
			if not retried then
				s.put_string (msg)
				Result := s.error_number
			else
				Result := -1
			end
		rescue
			retried := True
			retry
		end

	safe_ready_for_reading (s: like socket): INTEGER
		local
			retried: BOOLEAN
		do
			if not retried and then s.is_open_read then
				if s.ready_for_reading then
					Result := 1
				else
					Result := 0
				end
			else
				Result := - 1
				-- Should not occur
			end
		rescue
			retried := True
			retry
		end

	internal_read (s: like socket): STRING
		require
			ready_for_reading: s.ready_for_reading
		local
			retried: BOOLEAN
			bc: INTEGER
		do
			if not retried then
--				log ("[InternalRead] ...")
				from
					bc := 1
				until
					bc = 0
				loop
					s.read_stream (packet_size)
					bc := s.bytes_read
					if bc > 0 then
						if Result = Void then
							create Result.make (bc)
						end
						Result.append (s.last_string)
						if bc < packet_size then
							bc := 0
						end
					end
				end
			else
				if reconnect then
					do_reconnect
				else
					s.cleanup
--					socket := Void
				end
				Result := Void
			end
			if Result /= Void then
				log ("RECV[" + Result + "]", {XMPP_LOGGER}.log_debug)
			end
		rescue
			retried := True
			retry
		end

	process_xml	(a_xml: STRING)
		local
			l_parser: like parser
		do
			l_parser := parser
			parser.parse_from_string (a_xml)
		end

feature {NONE} -- XML callback

	start_xml (a_tag: XMPP_XML_TAG)
		do
			if been_reset then
				been_reset := False
				xml_depth := 0
			end
			xml_depth := xml_depth + 1
		end

	end_xml (a_tag: XMPP_XML_TAG)
		require
			a_tag_attached: a_tag /= Void
		local
			l_attribs: HASH_TABLE [STRING, STRING]
			l_tag: XMPP_XML_TAG
		do
			log ("[end_xml] " + a_tag.localname + " [" + xml_depth.out + "]", {XMPP_LOGGER}.log_debug)
			if been_reset then
				been_reset := False
				xml_depth := 0
			end
			xml_depth := xml_depth - 1
			if xml_depth = 1 then --|? a_tag.depth = 2 then
				l_attribs := a_tag.attribs

				if {xhdls: like xpath_handlers} xpath_handlers then
					from
						xhdls.start
					until
						xhdls.after
					loop
						if {xh: TUPLE [cases: LIST [TUPLE [path: STRING; name: STRING]]; hdl: like xpath_handler]} xhdls.item then
							l_tag := a_tag
							if {l_cases: LIST [TUPLE [path: STRING; name: STRING]]} xh.cases then
								from
									l_cases.start
								until
									l_cases.after
								loop
									if
										(l_tag.namespace = Void or else l_cases.item.path = Void or else l_tag.namespace.is_case_insensitive_equal (l_cases.item.path))
										and
										(l_cases.item.name.is_equal ("*") or l_cases.item.name.is_case_insensitive_equal (l_tag.localname))
									then
										log ("[Calling] " + l_cases.item.name, {XMPP_LOGGER}.log_info)
										xh.hdl.call ([a_tag])
									end
									l_cases.forth
								end
							end
						end
						xhdls.forth
					end
				end
				if {idhdls: like id_handlers} id_handlers then
					from
						idhdls.start
					until
						idhdls.after
					loop
						if l_attribs.has ("id") and then l_attribs.item ("id").is_case_insensitive_equal (idhdls.key_for_iteration) then
							if {ih: like id_handler} idhdls.item_for_iteration then
								ih.call ([a_tag])
							end
						end
						idhdls.forth
					end
				end
			end
			if xml_depth = 0 and not been_reset then
				if not disconnected then
					if not send_disconnect then
						send (stream_end)
					end
					disconnected := True
					send_disconnect := True
					socket.cleanup
					if reconnect then
						do_reconnect
					end
				end
				event (event_name_end_stream, Void)
			end
		end

feature -- Constants

	event_name_session_start: STRING = "session_start"
	event_name_end_stream: STRING = "end_stream"
	event_name_presence: STRING = "presence"
	event_name_message: STRING = "message"
	event_name_reconnect: STRING = "reconnect"
	event_name_subscription_requested: STRING = "subscription_requested"
	event_name_subscription_accepted: STRING = "subscription_accepted"


feature {NONE} -- Implementation

	raise_xmpp_exception (m: STRING)
		do
			log ("[XMPP Exception] " + m, {XMPP_LOGGER}.log_error)
			raise ("XMPP_EXCEPTION: " + m)
		end

	time: INTEGER_64
		local
			t: TIME
		do
			create t.make_now
			Result := t.duration.seconds_count
		end

--	microtime: INTEGER_64
--		local
--			dt: DATE_TIME
--		do
--			create dt.make_now
--			Result := dt.duration.seconds_count // 1_000_000
--		end

	time_point: INTEGER_64
		local
			t: TIME
		do
			create t.make_now
			Result := t.seconds
		end

	base64_encoded (s: STRING): STRING_8 is
		local
			e64: UT_BASE64_ENCODING_OUTPUT_STREAM
			o: UC_STRING
--			d64: UT_BASE64_DECODING_INPUT_STREAM
--			i: KL_STRING_INPUT_STREAM
		do
--			create i.make ("AHdlYgB3ZWI=")
--			create d64.make (i)
--			d64.read_string (12)

			create o.make_empty
			create e64.make (o, False, False)
			e64.put_string (s)
			e64.flush
			e64.close
			Result := o.string
		end

	base64_encoded_2 (s: STRING): STRING_8 is
			-- base64 encoded value of `s'.
		require
			s_not_void: s /= Void
		local
			i,n: INTEGER
			c: INTEGER
			f: SPECIAL [BOOLEAN]
			base64chars: STRING_8
		do
			base64chars := once "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
			from
				n := s.count
				i := (8 * n) \\ 6
				if i > 0 then
					create f.make (8 * n + (6 - i))
				else
					create f.make (8 * n)
				end
				i := 0
			until
				i > n - 1
			loop
				c := s.item (i + 1).code
				f[8 * i + 0] := c.bit_test(7)
				f[8 * i + 1] := c.bit_test(6)
				f[8 * i + 2] := c.bit_test(5)
				f[8 * i + 3] := c.bit_test(4)
				f[8 * i + 4] := c.bit_test(3)
				f[8 * i + 5] := c.bit_test(2)
				f[8 * i + 6] := c.bit_test(1)
				f[8 * i + 7] := c.bit_test(0)
				i := i + 1
			end
			from
				i := 0
				n := f.count
				create Result.make (n // 6)
			until
				i > n - 1
			loop
				c := 0
				if f[i + 0] then c := c + 0x20 end
				if f[i + 1] then c := c + 0x10 end
				if f[i + 2] then c := c + 0x8 end
				if f[i + 3] then c := c + 0x4 end
				if f[i + 4] then c := c + 0x2 end
				if f[i + 5] then c := c + 0x1 end
				Result.extend (base64chars.item (c + 1))
				i := i + 6
			end

			i := s.count \\ 3
			if i > 0 then
				from until i > 2 loop
					Result.extend ('=')
					i := i + 1
				end
			end
		ensure
			Result_not_void: Result /= Void
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
