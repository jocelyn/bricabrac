note
	description: "Summary description for {POP3_PROFILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POP3_PROFILE

create
	make,
	make_from_location

feature {NONE} -- Initialization

	make (a_host: STRING; a_port: INTEGER; a_username: STRING; a_password: STRING)
		do
			create_uuid
			host := a_host
			port := a_port
			username := a_username
			password := a_password
			enable
		end

	make_from_location (a_location: STRING; a_username: detachable STRING; a_password: STRING)
			-- rfc2384: pop://<user>;auth=<auth>@<host>:<port>
		require
			valid_location: (create {POP3_URL}.make (a_location)).is_valid (a_username = Void)
		local
			p,q,r: INTEGER
			a,s: detachable STRING
		do
			create_uuid
			password := a_password
			if a_username /= Void then
				username := a_username
			end

			p := a_location.index_of (':', 1)
			s := a_location.substring (1, p - 1)
				--| service = `s' .. should be "pop"
			check s.is_case_insensitive_equal ("pop") end
			check a_location.substring (p, p + 2).is_case_insensitive_equal ("://") end
			p := p + 3
			q := a_location.index_of ('@', p)
			if q > 0 then
				a := a_location.substring (p, q - 1)
				s := a_location.substring (q + 1, a_location.count)
				p := a.index_of (';', 1)
				if p > 0 then
					username := a.substring (1, p - 1)
					--| FIXME: handle the auth parameter
				else
					username := a
				end
			else
				check attached a_username end
				username := a_username
				s := a_location.substring (p, a_location.count)
			end
			p := s.index_of (':', 1)
			if p > 0 then
				host := s.substring (1, p - 1)
				s.remove_head (p)
				if s.is_integer then
					port := s.to_integer
				end
			else
				host := s
			end
			enable
		ensure
			host_attached: host /= Void
		end

feature -- Access

	uuid: STRING

	host: STRING

	port: INTEGER

	username: STRING

	password: STRING

	url: POP3_URL
		do
			create Result.make (host)
			Result.set_port (port)
			Result.set_username (username)
			Result.set_password (password)
		end

	location: STRING
		do
			Result := url.location
		end

feature -- Element change

	create_uuid
		do
			uuid := (create {UUID_GENERATOR}).generate_uuid.out
		end

	set_host (v: like host)
		do
			host := v
		end

	set_port (v: like port)
		require
			v_positive: v > 0
		do
			port := v
		end

	set_username (v: like username)
		do
			username := v
		end

	set_password (v: like password)
		do
			password := v
		end

feature -- status

	enabled: BOOLEAN
			-- Checking enabled?

feature -- Status setting

	enable
			-- Enable checking
		do
			enabled := True
		end

	disable
			-- Disable checking
		do
			enabled := False
		end


end
