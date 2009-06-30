indexing
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	POP_CHECKER_BATCH

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
			if attached command_line.separate_word_option_value ("p") as l_dir then
				set_profile_directory (l_dir)
			else
				set_profile_directory (current_working_directory)
			end
			create mail_checker_data.make (profile_directory)
			create logger.make_open_write (logger_filename)
			verbose := command_line.index_of_word_option ("v") > 0
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
					i := command_line.index_of_word_option ("-username")
					if i > 0 then
						l_username := command_line.argument (i + 1)
					end
					if l_username = Void or else l_username.is_empty then
						l_username := l_pop3_location.username
					end
					if l_username = Void or else l_username.is_empty then
						io.put_string ("Username?")
						io.read_line
						l_username := io.last_string.string
					end
					i := command_line.index_of_word_option ("-password")
					if i > 0 then
						l_password := command_line.argument (i + 1)
					end
					if l_password = Void or else l_password.is_empty then
						io.put_string ("Password?")
						io.read_line
						l_password := io.last_string.string
					end

					check not l_username.is_empty and not l_password.is_empty end
					create l_profile.make_from_location (n, l_username, l_password)
					l_profile.enable
					debug ("popchecker_io")
						io.put_string ("Saving profiles%N")
					end
					mail_checker_data.set_profile (l_profile)
					debug ("popchecker_io")
						io.put_string ("Checking email for profile%N")
					end
--					check_profile_authentication (l_profile)
					check_profile_and_report (l_profile)
				end
			else
				i := command_line.index_of_word_option ("-export")
				if i > 0 then
					export_profiles (profiles)
				else
					i := command_line.index_of_word_option ("a")
					if i > 0 then
						check_profiles (profiles, command_line.index_of_word_option ("-browser") > 0)
					else
						i := command_line.index_of_word_option ("c")
						if i > 0 and then attached command_line.argument (i + 1) as l_uuid then
							check_this_profile (l_uuid)
						else
							--| Default
							manage_profiles (profiles)
						end
					end
				end
			end
			logger.close

			debug ("popchecker_io")
				io.put_string ("Bye bye ...")
			end
		end

	mail_checker_data: MAIL_CHECKER_DATA

	logger: PLAIN_TEXT_FILE

	verbose: BOOLEAN

	profile_directory: STRING

	set_profile_directory (s: like profile_directory)
		local
			dn: DIRECTORY_NAME
		do
			profile_directory := s
			create dn.make_from_string (s)
			dn.extend ("offline")
			offline_directory := dn.string
		end

	offline_directory: STRING

	logger_filename: STRING is
		local
			fn: FILE_NAME
		do
			create fn.make_from_string (offline_directory)
			fn.set_file_name ("pop_checker.log")
			Result := fn.string
		end

	check_this_profile (a_uuid: STRING_8)
		local
			p: detachable POP3_PROFILE
		do
			p := mail_checker_data.profile_for (a_uuid)
			if p /= Void then
				check_profile_and_report (p)
			end
		end

	check_profiles_authentication (a_profiles: like profiles)
		local
			n: detachable STRING
			l_profile: like profile
			fn: FILE_NAME
			f: detachable PLAIN_TEXT_FILE
		do
			from
				a_profiles.start
			until
				a_profiles.after
			loop
				n := a_profiles.item
				l_profile := profile (n)
				if l_profile /= Void then
					check_profile_authentication (l_profile)
				end
				a_profiles.forth
			end
		end

	check_profiles (a_profiles: like profiles; open_index_file: BOOLEAN)
		local
			n: detachable STRING
			nb: INTEGER
			l_profile: like profile
			fn: FILE_NAME
			f: detachable PLAIN_TEXT_FILE
		do
			create fn.make_from_string (offline_directory)
			fn.set_file_name ("index.html")
			create f.make (fn)
			if not f.exists or else f.is_writable then
				f.open_write
				f.put_string (accounts_html_head ("Indexes"))
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
						f.put_string ("<li><a class=%"profile%" href=%"" + l_profile.uuid + "/" + "index.html%">")
						f.put_string (l_profile.location)
						f.put_string ("</a> : ")
						f.flush
					end
					if l_profile.enabled then
						check_profile (l_profile)
					end
					if f /= Void then
						if l_profile.enabled then
							if attached data (l_profile.uuid) as l_data then
								nb := l_data.new_messages_count
								if nb > 0 then
									f.put_string ("<span class=%"new%">")
									f.put_integer (nb)
									f.put_string (" new")
									f.put_string ("</span>")
									f.put_string (" out of ")
								end
								f.put_integer (l_data.messages_count)
								f.put_string (" message(s)")
								if l_data.counter > 0 then
									f.put_string (" (")
									f.put_natural_64 (l_data.counter)
									f.put_string (" archived)")
								end
								if attached l_data.logs as l_logs and then not l_logs.is_empty then
									f.put_string (" - <i>" + l_logs + "</i>")
								end

							end
						else
							f.put_string ("disabled")
						end
						f.put_string ("</li>%N")
						f.flush
					end
				end
				a_profiles.forth
			end
			if f /= Void then
				f.put_string ("</ul>%N")
				f.put_string (html_footer (Void))
				f.close
			end
			if open_index_file then
				if attached get ("ComSpec") as l_comspec then
					launch (l_comspec + " /C %"start " + fn + "%"")
				else
					launch ("firefox %"" + fn + "%"")
				end
			end
		end

	export_profiles (a_profiles: like profiles)
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
				a_profiles.start
			until
				a_profiles.after
			loop
				n := a_profiles.item
				l_profile := profile (n)
				if l_profile /= Void then
					print ("Profile: " + l_profile.location + " [" + n + "]%N")
					print ("  Host    =" + l_profile.host)
					if l_profile.port > 0 then
						print (":" + l_profile.port.out)
					end
					print ("%N")
					print ("  Username=" + l_profile.username + "%N")
					print ("  Password=" + l_profile.password + "%N")
					print ("  -add " + l_profile.location
							+ " --username " + l_profile.username
							+ " --password " + l_profile.password
							+ "%N")
				end
				a_profiles.forth
			end

		end

	manage_profiles (a_profiles: like profiles)
		require
			a_profiles_attached: a_profiles /= Void
		local
			l_profile: detachable POP3_PROFILE
			l_location: POP3_URL
			s, n, q, r: detachable STRING
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
					print ("(A,a) Check all profiles (a: only credential)%N")
					print ("Selection (q=quit)?")
					i := 0
					io.read_line
					q := io.last_string.string
					q.left_adjust
					q.right_adjust
					r := q.as_lower
					if r.is_integer then
						i := r.to_integer
						if i > 0 then
							l_profile := profs[i]
							manage_profile (l_profile)
						end
					elseif r.count > 0 and then r.item (1) = 'a' then
						if q.item (1) = 'a' then
							check_profiles_authentication (profiles)
						else
							check_profiles (profiles, command_line.index_of_word_option ("-browser") > 0)
						end
					elseif r.count > 0 and then r.item (1) = 'q' then
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
				print ("  5) Check authentication%N")
				print ("  6) Check emails%N")
				print ("  M) Back to previous menu%N")

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
						check_profile_authentication (a_prof)
					when 6 then
						check_profile_and_report (a_prof)
						q := Void
					else
						q := Void
					end
				elseif q.is_case_insensitive_equal ("m") then
					q := "menu"
				else
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
				print ("(same password)")
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

	check_profile_and_report (a_prof: POP3_PROFILE)
		do
			check_profile (a_prof)
			if attached data (a_prof.uuid) as l_data then
				if l_data.has_log then
					print ("Logs: " + l_data.logs + "%N")
				end
			end
		end

	check_profile_authentication (a_prof: POP3_PROFILE)
		do
			check_pop (a_prof.uuid, a_prof.host, a_prof.port, a_prof.username, a_prof.password, True)
		end

	check_profile (a_prof: POP3_PROFILE)
		do
			if a_prof.enabled then
				check_pop (a_prof.uuid, a_prof.host, a_prof.port, a_prof.username, a_prof.password, False)
			end
		end

	check_pop (a_uuid: STRING; a_server: STRING; a_port: INTEGER; a_user, a_pass: STRING; only_authentication: BOOLEAN)
		local
			l_url: POP3_URL
			s: detachable STRING
		do
			create l_url.make (a_server)
			if a_port > 0 then
				l_url.set_port (a_port)
			end
			l_url.set_username (a_user)
			l_url.set_password (a_pass)
			if only_authentication then

				s := check_authentication (l_url)
				print ("Authentication of " + l_url.location + ": ")
				if s = Void then
					print (" Ok")
				else
					print (" Wrong: " + s)
				end
				print ("%N")
			else
				check_pop_url (a_uuid, l_url)
			end
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
			l_force_update := command_line.index_of_word_option ("f") > 0
			if command_line.index_of_word_option ("h") > 0 then
				n := 0
			elseif attached command_line.separate_character_option_value ('n') as l_nb and then l_nb.is_integer then
				n := l_nb.to_integer
			else
				n := -1
			end
			check_account (a_url, l_data, n, l_force_update)
			debug ("popchecker_io")
				io.put_string ("Saving messages%N")
			end
			mail_checker_data.set_data (l_data)
			debug ("popchecker_io")
				io.put_string ("Saving messages: completed%N")
			end
			report_account (a_url, l_data)
			debug ("popchecker_io")
				io.put_string ("Reporting completed%N")
			end
		end

	check_authentication (a_url: POP3_URL): detachable STRING
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
				io.error.put_string ("%NCheck authentication " + a_url.location + "%N")
				logger.put_string (a_url.location)

				create pop.make_with_address (a_url)
				pop.set_read_mode
				pop.set_connect_timeout (500)
				pop.set_timeout (5)
				pop.open
				if not pop.error then
					pop.initiate_transfer
					if pop.transfer_initiated then
						pop.authenticate
					end
				end
				if pop.error then
					Result := pop.error_text (pop.error_code)
				end
			else
				Result := "Error occurred"
			end
			if pop /= Void then
				if pop.error then
					Result := pop.error_text (pop.error_code)
				end
				if pop.is_open then
					if pop.transfer_initiated and not pop.error then
						pop.quit
					end
					pop.close
				end
			else
				Result := "Error occurred"
			end
		rescue
			retried := True
			retry
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
			n: INTEGER
			retried: BOOLEAN
			l_is_new: BOOLEAN
		do
			if not retried then
					-- update location
				io.error.put_string ("Check account " + a_url.location + "%N")
				logger.put_string (a_url.location)
				a_mail_account.reset_logs

				create pop.make_with_address (a_url)
				pop.set_read_mode
				pop.open
				if not pop.error then
					pop.initiate_transfer
					if pop.transfer_initiated then
						pop.authenticate
					end
				end
				if pop.error then
					a_mail_account.add_log ("Error during authentication: " + pop.error_text (pop.error_code))
				else
					if attached pop.statistic as l_stat then
						l_msg_count := l_stat.nb
					end
					pop.reset_error

					mesgs := pop.message_uid_list (0)
					if pop.error then
						pop.reset_error
						mesgs := pop.message_id_list (0)
					end
					if not pop.error and mesgs /= Void then
						from
							a_mail_account.keep (mesgs)
							n := mesgs.count - a_mail_account.messages_count
							if n > 0 then
								io.error.put_string ("  -> ")
								io.error.put_integer (n)
								io.error.put_string (" new messages%N")
							end
							a_mail_account.set_new_messages_count (n)
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
							create l_log.make_from_string ("  #")
							l_log.append_integer (l_index)
							if l_msg_count > 0 then
							 	l_log.append_string ("/")
							 	l_log.append_integer (l_msg_count)
							end
							if l_uid /= Void then
								l_log.append_string (" <" + l_uid + ">")
							end
							logger.put_string (l_log)
							if verbose then
								io.error.put_string (l_log)
								io.error.put_new_line
							end

							if l_uid /= Void and then l_stored_messages.has_key (l_uid) then
								l_is_new := False
								l_mesg := l_stored_messages.found_item
								check l_mesg /= Void end
								if
									l_mesg.truncated and then
									(nb_lines_to_retrieve < 0 or else l_mesg.truncated_lines < nb_lines_to_retrieve)
								then
									l_mesg := Void
								end
							else
								l_is_new := True
							end
							if l_mesg = Void or a_force_update then
								l_mesg := mesgs.item
								if not verbose then
									io.error.put_string (l_log)
									io.error.put_new_line
								end
								io.error.put_string ("  GET: ")

								pop.get_message (l_mesg, nb_lines_to_retrieve)
								if pop.error then
									a_mail_account.add_log ("  Error while fetching message")
									io.error.put_string ("  ERROR!!!")
									io.error.put_new_line
								else
									io.error.put_string (l_mesg.to_string)
									io.error.put_new_line
								end
								pop.reset_error

								if l_uid /= Void then
									l_stored_messages.force (l_mesg, l_uid)
								end
							else
								debug ("popchecker_io")
									io.put_string ("  - already downloaded...%N")
								end
								l_mesg.update_index (l_index)
							end
							if l_is_new then
								a_mail_account.record_new_message (l_mesg)
							end
							logger.put_string (l_mesg.to_string)

							mesgs.forth
						end
	--					pop.query_top (3, 3)
					else
						pop.reset_error
						a_mail_account.add_log ("Error while fetching list")
					end
				end
				if pop.error then
					a_mail_account.add_log ("Error occurred [" + pop.error_text (pop.error_code) + "]")
				end
				if pop.is_open then
					if pop.transfer_initiated and not pop.error then
						pop.quit
					end
					pop.close
				end
			else
				if pop /= Void and then pop.error then
					a_mail_account.add_log ("Error occurred [" + pop.error_text (pop.error_code) + "]")
				else
					a_mail_account.add_log ("Error occurred")
				end
			end
			if pop /= Void and then pop.is_open then
				if pop.transfer_initiated and not pop.error then
					pop.quit
				end
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
			fn,hfn: FILE_NAME
			dir: DIRECTORY
			f: PLAIN_TEXT_FILE
			html_output: PLAIN_TEXT_FILE
			m: POP3_MESSAGE
		do
			create dn.make_from_string (offline_directory)
			dn.extend (a_mail_account.file_name)

			create msgs_dn.make_from_string (dn.string)
			msgs_dn.extend ("messages")

			create dir.make (dn.string)
			if not dir.exists then
				dir.create_dir
			end
			create dir.make (msgs_dn.string)
			if dir.exists then
				dir.recursive_delete
			end
			if not dir.exists then
				dir.create_dir
			end

			debug ("popchecker_io")
				io.put_string ("Reporting account%N")
			end
			create fn.make_from_string (dn)
			fn.set_file_name ("index.html")
			create html_output.make_open_write (fn.string)
			html_output.put_string (account_html_head (Void))

			html_output.put_string ("<div class=%"account%"><a class=%"rawtext%" href=%"../index.html%">" + a_url.location + "</a></div>%N")
			if attached a_mail_account.messages_by_date as l_messages and then not l_messages.is_empty then
				html_output.put_string ("<div class=%"info%">Messages: " + l_messages.count.out + "</div>%N")
				from
					i := l_messages.upper
					limit := l_messages.lower
				until
					i < limit
				loop
					debug ("popchecker_io")
						io.put_string (" - report message " + i.out + "%N")
					end
					m := l_messages[i]
					report_message ("", m, html_output, msgs_dn, a_mail_account.is_new_message (m))
					i := i - 1
				end
			end
			if attached a_mail_account.offline_messages_by_date as l_messages and then not l_messages.is_empty then
				html_output.put_string ("<div class=%"info%">Offline messages: " + l_messages.count.out + "</div>%N")
				from
					i := l_messages.upper
					limit := l_messages.lower
				until
					i < limit
				loop
					debug ("popchecker_io")
						io.put_string (" - report offline message " + i.out + "%N")
					end
					m := l_messages[i]
					report_message ("off", m, html_output, msgs_dn, False)
					i := i - 1
				end
			end
			html_output.put_string (html_footer (Void))
			html_output.put_string ("</body></html>%N")
			html_output.close
			debug ("popchecker_io")
				io.put_string ("Account reporting completed.")
			end
		end

	report_message (a_kind: STRING; a_mesg: POP3_MESSAGE; html_output: FILE; msgs_dn: DIRECTORY_NAME; is_new: BOOLEAN)
		local
			dhfn, dfn, hfn, fn: FILE_NAME
			f: PLAIN_TEXT_FILE
			s: detachable STRING
			l_output: FILE
		do
			create dhfn.make_from_string (a_kind + a_mesg.index.out + "-headers")
			dhfn.add_extension ("txt")

			create hfn.make_from_string (msgs_dn)
			hfn.set_file_name (dhfn.string)

			create f.make (hfn.string)
			if not f.exists or else f.is_writable then
				f.open_write -- comment this to make weird crash
				f.put_string (a_mesg.raw_headers_string)
				f.close
			end

			create dfn.make_from_string (a_kind + a_mesg.index.out)
			dfn.add_extension ("txt")

			create fn.make_from_string (msgs_dn)
			fn.set_file_name (dfn.string)

			create f.make (fn.string)
			if not f.exists or else f.is_writable then
				f.open_write -- comment this to make weird crash
				f.put_string (a_mesg.raw_message_string)
				f.close
			end
			html_output.put_string ("<div class=%"message%">")
			if is_new then
				html_output.put_string ("<div class=%"line new%">")
			else
				html_output.put_string ("<div class=%"line%">")
			end

			html_output.put_string ("<div class=%"synopsis%">")
			html_output.put_string ("<a href=%"messages/" + dfn  + "%">")

			html_output.put_string ("<span class=%"header%">")
			html_output.put_string ("#")
			html_output.put_integer (a_mesg.index)
			html_output.put_string ("</span>")

			if attached a_mesg.header_subject as l_text_subject then
				s := l_text_subject.string
				s.replace_substring_all ("<", "&lt;")
				s.replace_substring_all (">", "&gt;")
				html_output.put_string (" <span class=%"msubject%">" + s + "</span>")
			end
			html_output.put_string ("</a>")
			html_output.put_string ("</div>%N")
			html_output.put_string ("<div class=%"details%">")
			if attached a_mesg.header_from as l_text_from then
				s := l_text_from.string
				s.replace_substring_all ("<", "&lt;")
				s.replace_substring_all (">", "&gt;")

				html_output.put_string (" <span class=%"mfrom%">from: " + s + "</span>")
			end

			if attached a_mesg.header_to as l_text_to and then l_text_to.count > 0 then
				s := l_text_to.string
				s.replace_substring_all ("<", "&lt;")
				s.replace_substring_all (">", "&gt;")
				html_output.put_string (" <span class=%"mfrom%">to: " + s + "</span>")
			end

			if attached a_mesg.header_date as l_text_date then
				if attached a_mesg.header_date_time_yyyymmdd_hhmm as l_dt then
					html_output.put_string (" <span class=%"mdate%">")
					html_output.put_string (l_dt)
					html_output.put_string ("</span>")
				else
					html_output.put_string (" <span class=%"mdate%">" + l_text_date + "</span>")
				end
			end
			html_output.put_string ("<span class=%"header-opt%">")
			if attached a_mesg.uid as l_text_uid then
				html_output.put_string (" &lt;" + l_text_uid + "&gt;")
			end
			html_output.put_string (" <a class=%"rawheaders%" href=%"messages/" + dhfn  + "%">(headers)</a>")
			html_output.put_string ("</span>")
			html_output.put_string ("</div>%N") -- details
			html_output.put_string ("</div>%N") -- line
			html_output.put_string ("</div>%N%N") -- message
		end

	accounts_html_head (a_title: detachable STRING): STRING
		do
			create Result.make_empty
			Result.append_string ("<html><head>")
			Result.append_string ("<title>")
			if a_title /= Void then
				Result.append_string (a_title)
			else
				Result.append_string ("Email accounts")
			end
			Result.append_string ("</title>%N")
			Result.append_string ("[
					<link rel="stylesheet" type="text/css" href="../res/epop.css" />
					<script type="text/javascript" src="../res/jquery.js"></script>
					<script type="text/javascript" src="../res/epop.js"></script>
				]");
			Result.append_string ("%N</head><body>%N")
			Result.append_string ("<div id=%"accounts%" >%N")
		end

	account_html_head (a_title: detachable STRING): STRING
		do
			create Result.make_empty
			Result.append_string ("<html><head>")
			Result.append_string ("<title>")
			if a_title /= Void then
				Result.append_string (a_title)
			else
				Result.append_string ("Check Email")
			end
			Result.append_string ("</title>%N")
			Result.append_string ("[
					<link rel="stylesheet" type="text/css" href="../../res/epop.css" />
					<script type="text/javascript" src="../../res/jquery.js"></script>
					<script type="text/javascript" src="../../res/epop.js"></script>
				]");
			Result.append_string ("%N</head><body>%N")
			Result.append_string ("<div id=%"messages%" >%N")
		end

	html_footer (a_text: detachable STRING): STRING
		do
			Result := "</div>%N</body></html>%N"
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
