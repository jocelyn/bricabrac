note
	description: "Summary description for {POP3_MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POP3_MESSAGE

create
	make,
	make_with_uid

feature {NONE} -- Implementation

	make_with_uid (a_index: like index; a_uid: like uid)
		require
			valid_index: a_index > 0
			valid_id: a_uid /= Void and then not a_uid.is_empty
		do
			uid := a_uid
			make (a_index)
		end

	make (a_index: like index)
		require
			valid_index: a_index > 0
		do
			index := a_index
			create headers.make (5)
			truncated_lines := -1
		end

feature -- Access

	index: INTEGER
			-- Message index in POP3's list

	size: INTEGER
			-- Message size

	truncated_lines: INTEGER

	uid: detachable STRING
			-- Message UID

	message: detachable STRING
			-- Message's body

	headers_text: detachable STRING

	headers: HASH_TABLE [STRING, STRING]
			-- All information concerning each headers

	header (h: STRING): detachable STRING
			-- Retrieve the content of the header 'h'
		do
			Result := headers.item (h)
		end

	header_date_time: detachable DATE_TIME
		do
			if attached header_date as d then
				Result := date_time_from_string (d)
			end
		end

	status: INTEGER

	is_read: BOOLEAN
		do
			Result := status = 2
		end

	is_unread: BOOLEAN
		do
			Result := status = 1
		end

	is_new: BOOLEAN
		do
			Result := status = 0
		end

	set_new
		do
			status := 0
		end

	set_read
		do
			status := 2
		end

	set_unread
		do
			status := 1
		end


feature -- Access: header

	header_subject: like header do Result := header ("Subject") end
	header_from: like header do Result := header ("From") end
	header_return_path: like header do Result := header ("Return-Path") end
	header_to: like header do Result := header ("To") end
	header_date: like header do Result := header ("Date") end
	header_content_type: like header do Result := header ("Content-Type") end
	header_importance: like header do Result := header ("Importance") end
	header_message_id: like header do Result := header ("Message-ID") end
	header_mime_version: like header do Result := header ("MIME-Version") end
	header_delivered_to: like header do Result := header ("Delivered-To") end

feature -- status report

	raw_headers_string: STRING
		local
			h: like headers_text
		do
			h := headers_text
			if h /= Void then
				create Result.make_from_string (h)
			else
				create Result.make_empty
			end
		end

	raw_message_string: STRING
		local
			m: like message
		do
			m := message
			if m /= Void then
				create Result.make_from_string (m)
			else
				create Result.make (0)
			end
		end

	raw_string: STRING
		local
			m: like message
			h: like headers_text
		do
			m := message
			if m /= Void then
				create Result.make_from_string (m)
			else
				create Result.make (100)
			end
			h := headers_text
			if h /= Void then
				Result.prepend_string ("%N%N")
				Result.prepend_string (h)
			end
		end

	to_string: STRING
		local
		do
			create Result.make_empty
			if attached header_subject as l_subject then
				Result.append_string ("SUBJECT=%"" + l_subject + "%"" )
			end
			if attached header_from as l_from then
				Result.append_string (" FROM [" + l_from + "]" )
			end
			if attached header_date as l_date then
				Result.append_string (" (DATE:" + l_date + ")" )
			end
		end

	retrieved: BOOLEAN
		do
			Result := not headers.is_empty
		end

	truncated: BOOLEAN
		do
			Result := truncated_lines >= 0
		end

feature -- Element change

	update_index (a_index: like index)
		require
			a_index_valid: a_index > 0
		do
			index := a_index
		end

	reset_index
		do
			index := 0
		end

	set_truncated (a_nb_of_lines: INTEGER)
		do
			truncated_lines := a_nb_of_lines
		end

	set_size (a_size: like size)
		require
			vaid_size: a_size > 0
		do
			size := a_size
		end

	set_header_lines (a_lines: LIST [STRING])
		require
			a_lines_attached: a_lines /= Void
		local
			s, hk, hv, hv_k: detachable STRING
			h: like headers_text
			p: INTEGER
		do
			from
				create h.make (a_lines.count * 72)
				a_lines.start
			until
				a_lines.after
			loop
				s := a_lines.item
				h.append_string (s)
				h.append_string ("%N")
				if not s.item (1).is_space then
					check s[1] /= ' ' or s[1] /= '%T' end
					p := s.index_of (':', 1)
					check p > 0 end
					hk := s.substring (1, p - 1)
					hv := s.substring (p + 1 + 1, s.count) --| there is a space after the ':'
					if headers.has_key (hk) then
						hv_k := headers.found_item
						check hv_k /= Void end -- implied by `has_key'
						headers.force (hv_k + "%N" + hv, hk)
					else
						headers.force (hv, hk)
					end
--					print (" - " + hk + "%N")
				else
					check hv /= Void end
					hv.append_character ('%N')
					hv.append_string (s)
				end
				a_lines.forth
			end
			headers_text := h.string
		end

	set_message (s: like message)
		do
			if s = Void or else s.is_empty then
				message := Void
			else
				message := s
			end
		end

	reset_headers
		do
			headers.wipe_out
			headers_text := Void
		end

	reset_message
		do
			message := Void
		end

feature {NONE} -- Implementation

	locale_manager: I18N_LOCALE_MANAGER
		once
			create Result.make (Operating_environment.current_directory_name_representation)
		end

	locale_timezone_offset: INTEGER
		do
--			if attached locale_manager.locale (create {I18N_LOCALE_ID}.make_from_string ("LL-RR")) as locale then
--				print (locale.out)
--			end
			Result := 0
		end

	date_time_regexp: RX_PCRE_REGULAR_EXPRESSION
		once
			create Result.make
			Result.set_caseless (False)
			Result.set_multiline (False)
			Result.compile ("[a-zA-Z]+,\s{1}([0-3]?[0-9]) ([A-Z][a-z][a-z]) ([0-9]{4}) ([0-2][0-9]):([0-5][0-9]):([0-5][0-9])\s{1}([+-][0-9]{2})([0-9]{2})")
		end

	date_time_from_string (a_text: STRING): detachable DATE_TIME
			--| "18 May 2009 11:02:22 -0000"
			--| "Mon, 18 May 2009 11:00:03 +0000"
			--| "Mon, 18 May 2009 11:00:03 GMT"
		require
			a_text_attached: a_text /= Void
		local
			s,t: STRING
--			p: INTEGER
			hoff,moff: INTEGER
			r: like date_time_regexp
			d,m,y: INTEGER
			h,min,sec: INTEGER
		do
			s := a_text.string
			s.replace_substring_all ("GMT", "+0000")
			r := date_time_regexp
			r.match (s)
			if r.has_matched then
				d := r.captured_substring (1).to_integer
				s := r.captured_substring (2)
				if     s ~ "Jan" then m := 1
				elseif s ~ "Feb" then m := 2
				elseif s ~ "Mar" then m := 3
				elseif s ~ "Apr" then m := 4
				elseif s ~ "May" then m := 5
				elseif s ~ "Jun" then m := 6
				elseif s ~ "Jui" then m := 7
				elseif s ~ "Aug" then m := 8
				elseif s ~ "Sep" then m := 9
				elseif s ~ "Oct" then m := 10
				elseif s ~ "Nov" then m := 11
				elseif s ~ "Dec" then m := 12
				else check False end
				end
				y := r.captured_substring (3).to_integer
				h := r.captured_substring (4).to_integer
				min := r.captured_substring (5).to_integer
				sec := r.captured_substring (6).to_integer
				create Result.make (y, m, d, h, min, sec)

				if r.match_count > 6 then
					hoff := r.captured_substring (7).to_integer
					moff := r.captured_substring (8).to_integer
					Result.hour_add (-hoff)
					Result.minute_add (-moff)
				end
--			else
--				create s.make_from_string (a_text)
--				p := s.index_of (',', 1)
--				if p > 0 then
--					s := s.substring (p + 2, s.count)
--				end
--				p := s.last_index_of ('-', s.count)
--				if p = 0 then
--					p := s.last_index_of ('+', s.count)
--				end
--				if p > 0 then
--					t := s.substring (p, s.count)
--					if t.count = 5 then
--						t.keep_head (3)
--						if t.is_integer_32 then
--							hoff := t.to_integer
--						end
--					end
--					s.keep_head (p - 2)
--				end
--				create Result.make_from_string (s, "[0]dd MMM yyyy hh:[0]mi:[0]ss")
--				if hoff /= 0 then
--					Result.hour_add (-hoff)
--				end
			end
		end

end
