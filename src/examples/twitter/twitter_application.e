note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TWITTER_APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		local
			t: TWITTER_I
			s: STRING
			pref: like preferences
			ask_new: BOOLEAN
			retried: INTEGER
		do
			if retried <= 1 then
				pref := preferences (ask_new)
				create {TWITTER_JSON} t.make_with_source (pref.login, pref.password, "EiffelTwitter")
				if attached t.test as l_test then
					print (l_test)
				end

				if attached t.verify_credentials as l_user then
					print ("Authentication succeed...%N")
					test (t)
				else
					print ("Auth: BAD%N")
				end
			else
				print ("Bye ...%N")
			end
		rescue
			print ("Authentication failed. Retry ...%N")
			retried := retried + 1
			ask_new := True
			retry
		end

	test (t: TWITTER_I)
		local
			s: detachable STRING
			i: INTEGER
			a: detachable ANY
		do
			if attached t.rate_limit_status as rate then
				print ("  - hourly_limit   =" + rate.hourly_limit.out + "%N")
				print ("  - remaining_hits =" + rate.remaining_hits.out + "%N")
			end

			if attached t.public_timeline as l_public then
				print (l_public)
				print ("Public Time Line:%N")
				display_statuses (l_public)
			end
			if attached t.new_message ("djocenet", "This is a new message sent from EiffelTwitter") as l_mesg then
				display_message (l_mesg, False)
			end
			if attached t.direct_messages (Void, 0, 0) as l_messages then
				print ("Direct Messages:%N")
				display_messages (l_messages)
			end
			if attached t.sent_messages (Void, 0, 0) as l_messages then
				print ("Sent Messages:%N")
				display_messages (l_messages)
			end
			if attached t.user (0, "djocenet") as l_user then
				display_user (l_user, True)
				if attached l_user.status as l_status then
					if attached t.status (l_status.id) as l_full_status then
						display_status (l_full_status, True)
					end
				end
				a := t.update_profile (Void, Void, Void, "Somewhere", Void)
				if attached t.user (l_user.id, Void) as l_full_user then
					display_user (l_full_user, True)
				end
				a := t.update_profile (Void, Void, Void, l_user.location, Void)
			end

			from
				s := ""
				i := 0
			until
				s = Void
			loop
				io.put_string ("Post update:")
				io.read_line
				s := io.last_string
				check s /= Void end
				s := s.string
				s.left_adjust
				s.right_adjust
				if s.is_empty then
					s := Void
				else
					if attached t.update_status (s, i) as l_stat then
						i := l_stat.id
					end
				end
			end
		end

feature -- Status

feature -- Access

	display_status (a_status: TWITTER_STATUS; is_full: BOOLEAN)
		do
			if is_full then
				print (a_status.full_out)
			else
				print (a_status.short_out)
			end
			io.new_line
		end

	display_user (a_user: TWITTER_USER; is_full: BOOLEAN)
		do
			if is_full then
				print (a_user.full_out)
			else
				print (a_user.short_out)
			end
			io.new_line
		end

	display_message (a_mesg: TWITTER_MESSAGE; is_full: BOOLEAN)
		do
			if is_full then
				print (a_mesg.full_out)
			else
				print (a_mesg.short_out)
			end
			io.new_line
		end

	display_statuses (a_list: LIST [TWITTER_STATUS])
		do
			from
				a_list.start
			until
				a_list.after
			loop
				display_status (a_list.item, False)
				a_list.forth
			end
		end

	display_users (a_list: LIST [TWITTER_USER])
		do
			from
				a_list.start
			until
				a_list.after
			loop
				display_user (a_list.item, False)
				a_list.forth
			end
		end

	display_messages (a_list: LIST [TWITTER_MESSAGE])
		do
			from
				a_list.start
			until
				a_list.after
			loop
				display_message (a_list.item, False)
				a_list.forth
			end
		end

feature -- Change

	preferences (a_new: BOOLEAN): TUPLE [login: STRING; password: STRING]
		local
			d: detachable like preferences
			f: RAW_FILE
			s: detachable STRING
		do
			create f.make ("eiffel_twitter.data")
			if not a_new and f.exists and then f.is_readable then
				f.open_read
				d ?= f.retrieved
				f.close
			end
			if d /= Void then
				Result := d
			else
				create d
				io.put_string ("Please provide your twitter's account details.%N")
				io.put_string ("login: ")
				io.read_line
				s := io.last_string
				check s /= Void end
				d.login := s.string
				io.output.put_string ("password: ")
				io.read_line
				s := io.last_string
				check s /= Void end
				d.password := s.string
				f.open_write
				f.independent_store (d)
				f.close

				Result := d
			end
		end

note
	description: "Example Twitter client"
	copyright: "Copyright (c) 2003-2009, Jocelyn Fiat"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Jocelyn Fiat
			 Contact: jocelyn@eiffelsolution.com
			 Website http://www.eiffelsolution.com/
		]"
end
