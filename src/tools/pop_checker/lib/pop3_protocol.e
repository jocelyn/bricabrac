note
	description: "Summary description for {POP3_PROTOCOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POP3_PROTOCOL

inherit
	NETWORK_RESOURCE
		rename
			make as make_with_address
		end

	POP3_UTILITIES
		undefine
			is_equal
		end

create
	make,
	make_with_address

feature {NONE} -- Initialization

	make (a_host: STRING; a_port: INTEGER; a_username: STRING; a_passord: STRING)
			-- Initialize protocol.
		local
			add: POP3_URL
		do
			create add.make (a_host)
			if a_port /= 0 then
				add.set_port (a_port)
			end
			add.set_username (a_username)
			add.set_password (a_passord)

			make_with_address (add)
		end

feature {NONE} -- Initialization

	initialize
			-- Initialize protocol.
		do
			set_read_buffer_size (Default_buffer_size)
		end

feature {NONE} -- Constants

	Read_mode_id: INTEGER = unique

feature -- Access

	content_length: INTEGER

--	headers: HASH_TABLE [STRING, STRING]

feature -- Measurement

	count: INTEGER
			-- Size of data resource
		do
			if is_count_valid then
				Result := content_length
			end
		end

	Default_buffer_size: INTEGER = 16384
			-- Default size of read buffer.

feature -- Status report

	read_mode: BOOLEAN
			-- Is read mode set?
		do
			Result := (mode = Read_mode_id)
		end

	Write_mode: BOOLEAN = False
			-- Is write mode set? (Answer: no)

	valid_mode (n: INTEGER): BOOLEAN
			-- Is mode `n' valid?
		do
			Result := n = Read_mode_id
		end

	Supports_multiple_transactions: BOOLEAN = False
			-- Does resource support multiple tranactions per connection?
			-- (Answer: no)

feature -- Status setting

	open
			-- Open resource.
		local
			l_main_socket: like main_socket
		do
			if not is_open then
				if address.is_proxy_used then
					create l_main_socket.make_client_by_port
						(address.proxy_port, address.proxy_host)
				else
					create l_main_socket.make_client_by_port
							(address.port, address.host)
				end
				main_socket := l_main_socket
				l_main_socket.set_timeout (timeout)
				l_main_socket.set_connect_timeout (connect_timeout)
				l_main_socket.connect
			end
			if not is_open then
				error_code := Connection_refused
			else
				bytes_transferred := 0
				transfer_initiated := False
				is_packet_pending := False
				content_length := 0
			end
		rescue
			error_code := Connection_refused
		end

	close
			-- Close.
		local
			l_socket: like main_socket
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end
			l_socket.close
			if is_packet_pending then
				is_count_valid := False
			end
			main_socket := Void
			last_packet := Void
			is_packet_pending := False
			transfer_initiated := False
		rescue
			error_code := Transmission_error
		end

	initiate_transfer
			-- Initiate transfer.
		local
			s: detachable STRING
			l_socket: like main_socket
		do
			l_socket := main_socket
--			l_socket.set_reuse_address
			l_socket.set_nodelay
			check l_socket_attached: l_socket /= Void end
			if not error then
				s := single_answer_without_checking
				if s /= Void and then s.substring_index ("+OK", 1) = 1 then
					transfer_initiated := True
				else
					error_code := connection_refused
				end
			end
		end

	authenticate
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "USER " + address.username + "%R%N")
			s := single_answer_without_checking
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
			else
				error_code := no_such_user
			end

			if not error then
				socket_send_string (l_socket, "PASS " + address.password + "%N")
				s := single_answer_without_checking
				if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				else
					error_code := access_denied
				end
			end
		end

	quit
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "QUIT%N")
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("QUIT%N")
				end
			else
				error_code := Wrong_command
			end
		end

	statistic: detachable TUPLE [nb: INTEGER; length: INTEGER]
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
			p: INTEGER
			sc, sl: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "STAT%N")
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				s.remove_head (4)
				debug
					io.put_string ("Statistic: " + s + "%N")
				end
				p := s.index_of (' ', 1)
				check p > 0 end
				sc := s.substring (1, p - 1)
				sl := s.substring (p + 1, s.count)
				Result := [sc.to_integer, sl.to_integer]
			else
				error_code := Wrong_command
			end
		end

	send_noop
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "NOOP%N")
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("NOOP%N")
				end
			else
				error_code := Wrong_command
			end
		end

	query_rset
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "RSET%N")
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("RSET%N")
				end
			else
				error_code := Wrong_command
			end
		end

	message_id_list (a_msg_number: INTEGER): detachable ARRAYED_LIST [POP3_MESSAGE]
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
			i, n: INTEGER
			p: INTEGER
			m: detachable POP3_MESSAGE
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			if a_msg_number = 0 then
				socket_send_string (l_socket, "LIST%N")
			else
				socket_send_string (l_socket, "LIST " + a_msg_number.out + "%N")
			end
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("Messages: " + s.substring (4, s.count) + "%N")
				end
				if attached multiple_line_answer as lines then
					if lines.is_empty then
						create Result.make (0)
					else
						create Result.make (lines.count - 1)
						from
							lines.start
						until
							lines.after
						loop
							s := lines.item
							if not s.is_empty then
								p := s.index_of (' ', 1)
								i := s.substring (1, p).to_integer
								n := s.substring (p + 1, s.count).to_integer
								create m.make (i)
								m.set_size (n)
								Result.force (m)
							else
								debug
									io.error.put_string ("Error with [" + s + "]%N")
								end
							end
							lines.forth
						end
						debug
							io.put_string (s)
						end
					end
				end
			else
				error_code := Wrong_command
			end
		end

	message_uid_list (a_msg_number: INTEGER): detachable ARRAYED_LIST [POP3_MESSAGE]
		require
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
			i: INTEGER
			uid: detachable STRING
			p: INTEGER
			m: detachable POP3_MESSAGE
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			if a_msg_number = 0 then
				socket_send_string (l_socket, "UIDL%N")
			else
				socket_send_string (l_socket, "UIDL " + a_msg_number.out + "%N")
			end
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("Message UIDs: " + s.substring (4, s.count) + "%N")
				end
				if attached multiple_line_answer as lines then
					if lines.is_empty then
						create Result.make (0)
					else
						create Result.make (lines.count - 1)
						from
							lines.start
						until
							lines.after
						loop
							s := lines.item
							if not s.is_empty then
								p := s.index_of (' ', 1)
								i := s.substring (1, p).to_integer
								uid := s.substring (p + 1, s.count)
								create m.make_with_uid (i, uid)
								Result.force (m)
							else
								debug
									io.put_string ("Error with [" + s + "]%N")
								end
							end
							lines.forth
						end
						debug
							io.put_string (s)
						end
					end
				end
			else
				error_code := Wrong_command
			end
		end

	query_retrieve_message (a_msg_number: INTEGER)
		require
			a_msg_number_valid: a_msg_number > 0 -- check number exists
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "RETR " + a_msg_number.out + "%N")
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("Retrieve: " + s.substring (4, s.count) + "%N")
				end
				s := answer
				debug
					if s /= Void then
						io.put_string (s)
					end
				end
			else
				error_code := Wrong_command
			end
		end

	get_message (a_msg: POP3_MESSAGE; a_nb_of_lines: INTEGER)
		require
			a_msg_number_valid: a_msg.index > 0 -- check number exists
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s, m: detachable STRING
			h: detachable ARRAYED_LIST [STRING]
			b: BOOLEAN
			lines: detachable LIST [STRING]
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end
			a_msg.reset_headers
			a_msg.reset_message

			if a_nb_of_lines = 0 then
				socket_send_string (l_socket, "TOP " + a_msg.index.out + " 0%N")
			elseif a_nb_of_lines < 0 then
				socket_send_string (l_socket, "RETR " + a_msg.index.out + "%N")
			else
				socket_send_string (l_socket, "TOP " + a_msg.index.out + " " + a_nb_of_lines.out + "%N")
			end

			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("Get message: " + s.substring (4, s.count) + "%N")
				end
				lines := multiple_line_answer
				if lines /= Void then
					from
						create h.make (10)
						lines.start
					until
						lines.after
					loop
						s := lines.item
						if m = Void then --| still in headers
							if s.is_empty then
								create m.make_empty
							else
								h.force (s)
							end
						else
							m.append_string (s + "%N")
						end
						lines.forth
					end
					a_msg.set_header_lines (h)
--				end
--				if a_nb_of_lines /= 0 then
--					lines := multiple_line_answer
--					if lines /= Void then
--						create m.make_empty
--						from
--							lines.start
--						until
--							lines.after
--						loop
--							s := lines.item
--							if s /= Void then
--								m.append_string (s + "%N")
--							end
--							lines.forth
--						end
--					end
					a_msg.set_message (m)
				end
				if a_nb_of_lines >= 0 then
					a_msg.set_truncated (a_nb_of_lines)
				end
			else
				error_code := Wrong_command
			end
		end

	query_top (a_msg_number, a_nb_of_lines: INTEGER)
		require
			a_msg_number_valid: a_msg_number > 0 -- check number exists
			transfer_initiated: transfer_initiated
			no_error_occurred: not error
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket_attached: l_socket /= Void end

			socket_send_string (l_socket, "TOP " + a_msg_number.out + " " + a_nb_of_lines.out + "%N")
			s := single_answer
			if s /= Void and then s.substring_index ("+OK", 1) = 1 then
				debug
					io.put_string ("Top: " + s.substring (4, s.count) + "%N")
				end
				s := answer
				debug
					if s /= Void then
						io.put_string (s)
					end
				end
			else
				error_code := Wrong_command
			end
		end

--			str := Http_get_command.twin
--			str.extend (' ')
--			if address.is_proxy_used then
--				str.append (location)
--			else
--				str.extend ('/')
--				str.append (address.path)
--			end
--			str.extend (' ')
--			str.append (Http_version)
--			str.append (Http_end_of_header_line)

--			str.append (Http_host_header + ": " + address.host)
--			if address.port /= address.default_port then
--				str.append (":" + address.port.out)
--			end
--			if not address.username.is_empty then
--				str.append (Http_end_of_header_line)
--				str.append (Http_Authorization_header + ": Basic "
--						+ base64_encoded (address.username + ":" + address.password))
--			end
--			str.append (Http_end_of_command)
--			if not error then
--				l_socket := main_socket
--				check l_socket_attached: l_socket /= Void end
--				socket_send_string (l_socket, str)
--				debug ("eiffelnet")
--					Io.error.put_string (str)
--				end
--				get_headers
--				transfer_initiated := True
--				is_packet_pending := True
--			end
--		rescue
--			error_code := Transfer_failed
--		end

	set_read_mode
			-- Set read mode.
		do
			mode := Read_mode_id
		end

	 set_write_mode
	 		-- Set write mode.
		do
		end

feature {NONE} -- Implementation

	socket_send_string (a_socket: NETWORK_SOCKET; a_string: STRING)
			-- Send `a_string' into `a_socket'
		do
			debug ("pop")
				print ("SEND:" + a_string)
			end
			a_socket.put_string (a_string)
		end

	remove_trailing_r (s: STRING)
		do
			if not s.is_empty and then s.item (s.count) = '%R' then
				s.remove_tail (1)
			end
		end

	answer: detachable STRING
		local
			l_socket: like main_socket
			s: detachable STRING
		do
			l_socket := main_socket
			check l_socket /= Void end
			if not error then
				from
					create Result.make_empty
				until
					error or else (s /= Void and then s.is_equal ("."))
				loop
					check_socket (l_socket, Read_only)
					if not error then
						l_socket.read_line
						s := l_socket.last_string
						remove_trailing_r (s)
						Result.append_string (s + "%N")
					end
				end
			end
		end

	multiple_line_answer: detachable LIST [STRING]
		local
			l_socket: like main_socket
			s: detachable STRING
			l_stop: BOOLEAN
		do
			l_socket := main_socket
			check l_socket /= Void end
			if not error then
				from
					create {ARRAYED_LIST [STRING]} Result.make (100)
				until
					error or l_stop
				loop
					check_socket (l_socket, Read_only)
					if not error then
						l_socket.read_line
						s := l_socket.last_string.string
						remove_trailing_r (s)
						if s.count = 1 and then s[1] = '.' then
							l_stop := True
						else
							Result.force (s)
						end
					end
				end
			end
		end

	multiple_line_answer2 (stop_at_first_dot_line: BOOLEAN): detachable LIST [STRING]
		local
			l_stop_at_dot_line: BOOLEAN
			l_socket: like main_socket
			s: detachable STRING
		do
			l_stop_at_dot_line := stop_at_first_dot_line
			l_socket := main_socket
			check l_socket /= Void end
			if not error then
				from
					create {ARRAYED_LIST [STRING]} Result.make (100)
				until
					error or s /= Void
				loop
					check_socket (l_socket, Read_only)
					if not error then
						l_socket.read_line
						s := l_socket.last_string.string
						remove_trailing_r (s)
						if s.count = 1 and then s[1] = '.' then
							if not l_stop_at_dot_line then
								l_stop_at_dot_line := True
							else
								s := Void
							end
						else
							Result.force (s)
						end
					end
				end
			end
		end

	single_answer_without_checking: detachable STRING
		do
			Result := impl_single_answer (False)
		end

	single_answer: detachable STRING
		do
			Result := impl_single_answer (True)
		end

	impl_single_answer (a_check: BOOLEAN): detachable STRING
		local
			l_socket: like main_socket
		do
			l_socket := main_socket
			check l_socket /= Void end
			if not error then
				if a_check then
					check_socket (l_socket, Read_only)
				end
				if not error then
					l_socket.read_line
					Result := l_socket.last_string.string
					debug ("pop")
						print ("RECV:" + Result + "%N")
					end
					remove_trailing_r (Result)
				end
			end
		end

feature {NONE} -- Status setting

	open_connection
			-- Open the connection.
		do
			open
		end


invariant

--	headers_list_exists: headers /= Void
--	count_constraint: (is_count_valid and count > 0) implies
--				(is_packet_pending = (bytes_transferred < count))

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"





end
