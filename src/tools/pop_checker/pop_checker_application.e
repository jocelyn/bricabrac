indexing
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	POP_CHECKER_APPLICATION

inherit
	EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		local
			i: INTEGER
			l_profile: like profile
			l_profiles: like profiles
			n, l_username, l_password: detachable STRING
--			l_pop3_location: POP3_LOCATION
		do
			if attached command_line.separate_character_option_value ('p') as l_dir then
				profile_directory := l_dir
			else
				profile_directory := current_working_directory
			end
			create mail_checker_data.make (profile_directory)
			create logger.make_open_write (logger_filename)
			i := command_line.index_of_word_option ("add")
			if i > 0 then
				n := command_line.argument (i + 1)
				if mail_checker_data.profile_with_location (n) /= Void then
					io.error.put_string ("ERROR: account %"" + n + "%" already exists!%N")
					io.put_string ("Do you want to overwrite it (Y|N) ?")
					io.read_line
					if
						attached io.last_string as l_reply and then
						(l_reply.count = 0 or else l_reply.item (1).as_lower /= 'y')
					then
						n := Void
					end
				end
				if n /= Void and then attached (create {POP3_URL}.make (n)) as l_pop3_location and then l_pop3_location.is_valid (False) then
					io.put_string ("Location: " + n + "%N")
					l_username := l_pop3_location.username
					if l_username.is_empty then
						io.put_string ("Username?")
						io.read_line
						l_username := io.last_string.string
					end
					io.put_string ("Password?")
					io.read_line
					l_password := io.last_string.string

					check not l_username.is_empty and not l_password.is_empty end
					create l_profile.make_from_location (n, l_username, l_password)
					l_profile.enable
					mail_checker_data.set_profile (l_profile)
					check_profile (l_profile)
				end
			else
				i := command_line.index_of_character_option ('a')
				if i > 0 then
					check_profiles (profiles)
				else
					i := command_line.index_of_character_option ('c')
					if i > 0 and then attached command_line.argument (i + 1) as l_uuid then
						check_this_profile (l_uuid)
					else
						--| Default
						manage_profiles (profiles)
					end
				end
			end
			logger.close
		end

	mail_checker_data: MAIL_CHECKER_DATA

	logger: PLAIN_TEXT_FILE

	profile_directory: STRING

	logger_filename: STRING is
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (profile_directory)
			fn.set_file_name ("pop_checker.log")
			Result := fn.string
		end

	profiles_edb_filename: STRING is
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (profile_directory)
			fn.set_file_name ("profiles.edb")
			Result := fn.string
		end

	data_edb_filename: STRING is
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (profile_directory)
			fn.set_file_name ("messages.edb")
			Result := fn.string
		end

	check_this_profile (a_uuid: STRING_8)
		local
			p: detachable POP3_PROFILE
		do
			p := mail_checker_data.profile_for (a_uuid)
			if p /= Void then
				check_profile (p)
			end
		end

	check_profiles (a_profiles: like profiles)
		local
			n: detachable STRING
			l_profile: like profile
			fn: FILE_NAME
			f: detachable PLAIN_TEXT_FILE
		do
			create fn.make_from_string (profile_directory)
			fn.set_file_name ("index.html")
			create f.make (fn)
			if not f.exists or else f.is_writable then
				f.open_write
				f.put_string (html_head ("Indexes"))
				f.put_string ("<h1>Checking emails</h1>%N")
				f.put_string ("<ul>%N")
			else
				f := Void
			end

			from
				a_profiles.start
			until
				a_profiles.after
			loop
				n := a_profiles.item
				l_profile := profile (n)
				if l_profile /= Void then
					if f /= Void then
						f.put_string ("<li><a href=%"" + l_profile.uuid + "/" + "index.html%">" + l_profile.location + "</a></li>")
						f.flush
					end
					check_profile (l_profile)
				end
				a_profiles.forth
			end
			if f /= Void then
				f.put_string ("</ul>%N")
				f.put_string (html_footer (Void))
				f.close
			end
			if attached get ("ComSpec") as l_comspec then
				launch (l_comspec + " /C %"start " + fn + "%"")
			end
		end

	manage_profiles (a_profiles: like profiles)
		require
			a_profiles_attached: a_profiles /= Void
		local
			l_profile: detachable POP3_PROFILE
			l_location: POP3_URL
			s, n, q: detachable STRING
			i,m: INTEGER
			profs: ARRAY [POP3_PROFILE]
		do
			from
				i := 0
			until
				i = -1
			loop
				if a_profiles.count > 0 then
					from
						a_profiles.start
						create profs.make (1, a_profiles.count)
						i := 0
					until
						a_profiles.after
					loop
						n := a_profiles.item
						l_profile := profile (n)
						if l_profile /= Void then
							i := i + 1
							profs [i] := l_profile
						end
						a_profiles.forth
					end
					from
						i := profs.lower
					until
						i > profs.upper
					loop
						l_profile := profs[i]
						if l_profile /= Void then
							print ("(" + i.out + ") ")
							display_profile (l_profile, 0)
						end
						i := i + 1
					end
					print ("Selection (q=quit)?")
					i := 0
					io.read_line
					q := io.last_string.string
					q.to_lower
					q.left_adjust
					q.right_adjust
					if q.is_integer then
						i := q.to_integer
						if i > 0 then
							l_profile := profs[i]
							manage_profile (l_profile)
						end
					elseif q.count > 0 and then q.item (1) = 'q' then
						i := -1
					end
				else
					print ("Create a new profile [Y|n]?")
					io.read_line
					q := io.last_string.string
					q.to_lower
					q.left_adjust
					q.right_adjust
					if q.count > 0 and then q.item (1) = 'y' then
						print ("Location: pop://username@host:port/ ?")
						io.read_line
						q := io.last_string.string
						q.left_adjust
						q.right_adjust
						create l_location.make (q)
						if l_location.is_valid (False) then
							s := l_location.username
							if s = Void then
								print ("Username ?")
								io.read_line
								s := io.last_string.string
								s.left_adjust
								s.right_adjust
								if s.is_empty then
									s := Void
								end
							end
							print ("Password ?")
							io.read_line

							create l_profile.make_from_location (l_location.location, s, io.last_string.string)
							display_profile (l_profile, 1)
							mail_checker_data.set_profile (l_profile)
						else
							print ("Invalid location%N")
						end
					else
						i := -1
					end
				end
			end
		end

	manage_profile (a_prof: POP3_PROFILE)
		local
			q: detachable STRING
		do
			display_profile (a_prof, 1)
			from
			until
				q /= Void
			loop
				print ("  1) Show all details%N")
				print ("  2) Edit%N")
				if a_prof.enabled then
					print ("  3) Disable%N")
				else
					print ("  3) Enable%N")
				end
				print ("  4) Delete%N")
				print ("  5) Cancel%N")
				print ("  6) Check email%N")
				print ("     Select operation:")
				io.read_line
				q := io.last_string
				q.left_adjust
				q.right_adjust
				q.to_lower
				if q.is_integer then
					inspect q.to_integer
					when 1 then
						display_profile (a_prof, 2)
						q := Void
					when 2 then
						edit_profile (a_prof)
						mail_checker_data.set_profile (a_prof)
						display_profile (a_prof, 2)
						q := Void
					when 3 then
						if a_prof.enabled then
							a_prof.disable
						else
							a_prof.enable
						end
						mail_checker_data.set_profile (a_prof)
						display_profile (a_prof, 2)
						q := Void
					when 4 then
						delete_this_profile (a_prof)
					when 5 then
						q := "cancel"
					when 6 then
						check_profile (a_prof)
					else
						q := Void
					end
				end
			end
		end

	edit_profile (a_prof: POP3_PROFILE)
		local
			s: detachable STRING
			i: INTEGER
		do
			print ("Hostname ")
			if attached a_prof.host as h then
				print ("(" + h + ")")
			end
			print (": ")
			io.read_line; s := io.last_string; s.left_adjust; s.right_adjust
			if not s.is_empty then
				a_prof.set_host (s.string)
			end

			print ("Port ")
			i := a_prof.port
			if i > 0 then
				print ("(" + i.out + ")")
			end
			print (": ")
			io.read_line; s := io.last_string; s.left_adjust; s.right_adjust
			if not s.is_empty and s.is_integer then
				i := s.to_integer
				if i > 0  then
					a_prof.set_port (i)
				end
			end

			print ("Username ")
			if attached a_prof.username as u then
				print ("(" + u + ")")
			end
			print (": ")
			io.read_line; s := io.last_string; s.left_adjust; s.right_adjust
			if not s.is_empty then
				a_prof.set_username (s.string)
			end

			print ("Password ")
			if attached a_prof.password as p then
				print ("(" + p + ")")
			end
			print (": ")
			io.read_line
			s := io.last_string
			if not s.is_empty then
				a_prof.set_password (s.string)
			end
		end

	delete_this_profile (a_prof: POP3_PROFILE)
		do
			mail_checker_data.delete_profile (a_prof)
		end

	display_profile (a_prof: POP3_PROFILE; d: INTEGER)
		do
			print ("Profile [" + a_prof.location + "]")
			if a_prof.enabled then
				print (" - enabled - ")
			else
				print (" - disabled - ")
			end
			print ("%N")
			if d >= 1 then
				print ("  uuid=" + a_prof.uuid + "%N")
				print ("  host=" + a_prof.host + "%N")
				print ("  port=" + a_prof.port.out + "%N")
				print ("  username=" + a_prof.username + "%N")
				if d >= 2 then
					print ("  password=" + a_prof.password + "%N")
				end
			end
		end

	check_profile (a_prof: POP3_PROFILE)
		do
			if a_prof.enabled then
				check_pop (a_prof.uuid, a_prof.host, a_prof.port, a_prof.username, a_prof.password)
			end
		end

	check_pop (a_uuid: STRING; a_server: STRING; a_port: INTEGER; a_user, a_pass: STRING)
		local
			l_url: POP3_URL
		do
			create l_url.make (a_server)
			if a_port > 0 then
				l_url.set_port (a_port)
			end
			l_url.set_username (a_user)
			l_url.set_password (a_pass)
			check_pop_url (a_uuid, l_url)
		end

	check_pop_url (a_uuid: STRING; a_url: POP3_URL)
		local
			l_data: like data
			n: INTEGER
			l_force_update: BOOLEAN
		do
			l_data := data (a_uuid)
			if l_data = Void then
				create l_data.make (a_uuid)
			end
			l_force_update := command_line.index_of_character_option ('f') > 0
			if command_line.index_of_character_option ('h') > 0 then
				n := 0
			elseif attached command_line.separate_character_option_value ('n') as l_nb and then l_nb.is_integer then
				n := l_nb.to_integer
			else
				n := -1
			end
			check_account (a_url, l_data, n, l_force_update)
			mail_checker_data.set_data (l_data)
			report_account (a_url, l_data)
		end

	check_account (a_url: POP3_URL; a_mail_account: POP3_MESSAGES_DATA; nb_lines_to_retrieve: INTEGER; a_force_update: BOOLEAN)
		local
			pop: detachable POP3_PROTOCOL
			s: detachable STRING
			mesgs: detachable LIST [POP3_MESSAGE]
			l_stored_data: like data
			l_stored_messages: HASH_TABLE [POP3_MESSAGE, STRING]
			l_uids: ARRAYED_LIST [STRING]
			l_index: INTEGER
			l_uid: detachable STRING
			l_mesg: detachable POP3_MESSAGE
			l_msg_count: INTEGER
			l_log: detachable STRING
			retried: BOOLEAN
		do
			if not retried then
					-- update location
				io.error.put_string ("%NCheck account " + a_url.location + "%N")
				logger.put_string (a_url.location)

				create pop.make_with_address (a_url)
				pop.set_read_mode
				pop.open
				if not pop.error then
					pop.initiate_transfer
					if pop.transfer_initiated then
						pop.authenticate
					end
				end
				if not pop.error then
					if attached pop.statistic as l_stat then
						l_msg_count := l_stat.nb
					end
					pop.reset_error

					mesgs := pop.message_uid_list (0)
					if pop.error then
						pop.reset_error
						mesgs := pop.message_id_list (0)
					end
					if not pop.error then
						check mesgs /= Void end
						from
							a_mail_account.keep (mesgs)
							l_stored_messages := a_mail_account.messages
							create l_uids.make (mesgs.count)
							mesgs.start
							logger.put_string ("%N")
						until
							mesgs.after
						loop
							l_mesg := mesgs.item
							l_uid := l_mesg.uid
							l_index := l_mesg.index
							l_mesg := Void
							create l_log.make_from_string ("Message: #")
							l_log.append_integer (l_index)
							if l_msg_count > 0 then
							 	l_log.append_string (" / ")
							 	l_log.append_integer (l_msg_count)
							end
							if l_uid /= Void then
								l_log.append_string (" <" + l_uid + ">")
							end
--							l_log.append_string ("%")
							logger.put_string (l_log)
							io.error.put_string (l_log)
							io.error.put_new_line

							if l_uid /= Void and then l_stored_messages.has_key (l_uid) then
								l_mesg := l_stored_messages.found_item
								check l_mesg /= Void end
								if l_mesg.truncated and then nb_lines_to_retrieve < 0 or else l_mesg.truncated_lines < nb_lines_to_retrieve then
									l_mesg := Void
								end
							end
							if l_mesg = Void or a_force_update then
								io.error.put_string ("  - downloading...%N")
								l_mesg := mesgs.item
								pop.get_message (l_mesg, nb_lines_to_retrieve)
								pop.reset_error
								if l_uid /= Void then
									l_stored_messages.force (l_mesg, l_uid)
								end
							else
	--							io.put_string ("  - already downloaded...%N")
								l_mesg.update_index (l_index)
							end
							logger.put_string (l_mesg.to_string + "")

							mesgs.forth
						end
	--					pop.query_top (3, 3)
					else
						pop.reset_error
					end
				end
				if pop.is_open then
					if pop.transfer_initiated then
						pop.quit
					end
					pop.close
				end
			else

			end
			if pop /= Void and then pop.is_open then
				pop.quit
				pop.close
			end
		rescue
			retried := True
			retry
		end

	report_account (a_url: POP3_URL; a_mail_account: POP3_MESSAGES_DATA)
		local
			i,limit: INTEGER
			s: detachable STRING
			dn: DIRECTORY_NAME
			msgs_dn: DIRECTORY_NAME
			fn: FILE_NAME
			dir: DIRECTORY
			f: PLAIN_TEXT_FILE
			html_output: PLAIN_TEXT_FILE
		do
			create dn.make_from_string (profile_directory)
			dn.extend (a_mail_account.file_name)

			create msgs_dn.make_from_string (dn.string)
			msgs_dn.extend ("messages")

			create dir.make (dn.string)
			if not dir.exists then
				dir.create_dir
			end
			create dir.make (msgs_dn.string)
			if not dir.exists then
				dir.create_dir
			end


			create fn.make_from_string (dn)
			fn.set_file_name ("index.html")
			create html_output.make_open_write (fn.string)
			html_output.put_string (html_head (Void))

			html_output.put_string ("<div class=%"account%">" + a_url.location + "</div>%N")
			if attached a_mail_account.messages_by_index as l_messages then
				from
					i := l_messages.upper
					limit := l_messages.lower
				until
					i < limit
				loop
					if attached l_messages[i] as l_mesg then
						create fn.make_from_string (msgs_dn)
						fn.set_file_name (l_mesg.index.out)
						fn.add_extension ("txt")
						create f.make (fn.string)
						if not f.exists or else f.is_writable then
							f.open_write -- comment this to make weird crash
							f.put_string (l_mesg.raw_string)
							f.close
						end

						html_output.put_string ("<div class=%"line%">")
						html_output.put_string ("<a href=%"messages/" + l_mesg.index.out  + ".txt%">")

						html_output.put_string ("<span class=%"header%">")
						html_output.put_string ("#")
						html_output.put_integer (l_mesg.index)
						html_output.put_string ("</span>")

						html_output.put_string ("<span class=%"content%">")
						if attached l_mesg.header_subject as l_text_subject then
							s := l_text_subject.string
							s.replace_substring_all ("<", "&lt;")
							s.replace_substring_all (">", "&gt;")
							html_output.put_string (" <span class=%"msubject%">" + s + "</span>")
						end
						html_output.put_string ("</a>")
						html_output.put_string ("<br/>&nbsp;&nbsp;&nbsp;&nbsp; ")
						if attached l_mesg.header_from as l_text_from then
							s := l_text_from.string
							s.replace_substring_all ("<", "&lt;")
							s.replace_substring_all (">", "&gt;")

							html_output.put_string (" <span class=%"mfrom%">from: " + s + "</span>")
						end
						if attached l_mesg.header_to as l_text_to and then l_text_to.count > 0 then
							s := l_text_to.string
							s.replace_substring_all ("<", "&lt;")
							s.replace_substring_all (">", "&gt;")
							html_output.put_string (" <span class=%"mfrom%">to: " + s + "</span>")
						end

						if attached l_mesg.header_date as l_text_date then
							if attached l_mesg.header_date_time as l_dt then
								html_output.put_string (" <span class=%"mdate%">")
								html_output.put_integer (l_dt.year)
								html_output.put_character ('/')
								html_output.put_integer (l_dt.month)
								html_output.put_character ('/')
								html_output.put_integer (l_dt.day)
								html_output.put_character ('-')
								html_output.put_integer (l_dt.hour)
								html_output.put_character (':')
								html_output.put_integer (l_dt.minute)
								html_output.put_string ("</span>")
							else
								html_output.put_string (" <span class=%"mdate%">" + l_text_date + "</span>")
							end
						end
						html_output.put_string ("</span>")
						if attached l_mesg.uid as l_text_uid then
							html_output.put_string ("<span class=%"header-opt%">")
							html_output.put_string (" &lt;" + l_text_uid + "&gt;")
							html_output.put_string ("</span>")
						end
						html_output.put_string ("</div>%N")
					end
					i := i - 1
				end
			end
			html_output.put_string (html_footer (Void))
			html_output.put_string ("</body></html>%N")
			html_output.close
		end

	html_head (a_title: detachable STRING): STRING
		do
			create Result.make_empty
			Result.append_string ("<html><head>")
			Result.append_string ("<title>")
			if a_title /= Void then
				Result.append_string (a_title)
			else
				Result.append_string ("Check Email")
			end
			Result.append_string ("</title>")
			Result.append_string ("<style>%N")
			Result.append_string (" a { text-decoration: none; }%N")
			Result.append_string (" .account {font-weight: bold; color: #900; }%N")
			Result.append_string (" .line { font-size: 75%%; padding-top: 2px; border-bottom: solid 1px #ddd; }%N")
			Result.append_string (" .header { font-style: italic; color: #999; }%N")
			Result.append_string (" .header-opt { font-style: italic; color: #999; }%N")
			Result.append_string (" .msubject {font-weight: bold; color: #00a }%N")
			Result.append_string (" .mfrom {color: #090; }%N")
			Result.append_string (" .mdate {font-style: italic; color: #600; }%N")
			Result.append_string (" .content {color: #000; }%N")
			Result.append_string ("</style>%N")
			Result.append_string ("</head><body>%N")
		end


	html_footer (a_text: detachable STRING): STRING
		do
			Result := "</body></html>%N"
		end

feature -- Access

	profiles: LIST [STRING_8]
		do
			Result := mail_checker_data.profile_uuids
		end

	profile (a_uuid: STRING_8): detachable POP3_PROFILE
		do
			Result := mail_checker_data.profile (a_uuid)
		end

	data (a_uuid: STRING_8): detachable POP3_MESSAGES_DATA
		do
			Result := mail_checker_data.data (a_uuid)
		end

feature -- Helper

end
