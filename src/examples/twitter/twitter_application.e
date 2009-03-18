note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TWITTER_APPLICATION

inherit
	ANY

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		local
			t: TWITTER_JSON
			s: STRING
			pref: like preferences
			ask_new: BOOLEAN
			retried: INTEGER
		do
			if retried <= 1 then
				pref := preferences (ask_new)
--				create t.make (pref.login, pref.password)
				create t.make_with_source (pref.login, pref.password, "EiffelTwitter")

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

	test (t: TWITTER_JSON)
		local
			s: detachable STRING
			i: INTEGER
		do
			if attached t.rate_limit_status as rate then
				print ("  - hourly_limit   =" + rate.hourly_limit.out + "%N")
				print ("  - remaining_hits =" + rate.remaining_hits.out + "%N")
			end

			if attached t.show_status (10377782) as l_status then
				print (l_status)
			end
			if attached t.show_user (0, "djocenet") as l_user then
				print (l_user)
			end
			if attached t.show_user (10377782, Void) as l_user then
				print (l_user)
			end

--			s := t.public_timeline (0)
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

feature {NONE} -- Implementation


end
