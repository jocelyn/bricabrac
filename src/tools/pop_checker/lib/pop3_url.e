note
	description:
		"URLs for POP resources"
	legal: "See notice at end of class."

	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class POP3_URL

inherit
	NETWORK_RESOURCE_URL
		redefine
			location,
			analyze
		end

create
	make

feature -- Access

	Service: STRING = "pop"
			-- Name of service (Answer: "pop")

	authentication: detachable STRING
			-- Use APOP for authentication

feature -- Status report

	Default_port: INTEGER = 110
			-- Number of default port for service (Answer: 110)

	Is_proxy_supported: BOOLEAN = True
			-- Are proxy connections supported? (Answer: yes)

	Has_username: BOOLEAN = True;
			-- Can address contain a username?

	is_valid (a_username_required: BOOLEAN): BOOLEAN
			-- rfc2384: pop://<user>;auth=<auth>@<host>:<port>
		do
			Result := is_correct and then (not a_username_required or else username /= Void)
		end

feature -- Access

	raw_url_encode (s: STRING)
			-- cf RFC 1738
		do
			s.replace_substring_all ("%%", "%%25")
			s.replace_substring_all (";", "%%3B")
			s.replace_substring_all ("/", "%%2F")
			s.replace_substring_all ("?", "%%3F")
			s.replace_substring_all (":", "%%3A")
			s.replace_substring_all ("@", "%%40")
			s.replace_substring_all ("=", "%%3D")
			s.replace_substring_all ("&", "%%26")
		end

	raw_url_decode (s: STRING)
			-- cf RFC 1738
		do
			s.replace_substring_all ("%%26", "&")
			s.replace_substring_all ("%%3B", ";")
			s.replace_substring_all ("%%2F", "/")
			s.replace_substring_all ("%%3F", "?")
			s.replace_substring_all ("%%3A", ":")
			s.replace_substring_all ("%%40", "@")
			s.replace_substring_all ("%%3D", "=")
			s.replace_substring_all ("%%25", "%%")
		end

	location: STRING
			-- Full URL of resource
			-- rfc2384: pop://<user>;auth=<auth>@<host>:<port>
		local
			s: detachable STRING
		do
			create Result.make_from_string (service)
			Result.append ("://")

			if not username.is_empty then
				create s.make_from_string (username)
				raw_url_encode (s)
			end
			if attached authentication as l_auth then
				if s = Void then
					create s.make_empty
				end
				s.append_string (";AUTH=" + l_auth)
			end
			if s /= Void then
				Result.append_string (s)
				Result.append_character ('@')
			end
			Result.append (host)
			if port /= 0 and port /= default_port then
				Result.append_character (':')
				Result.append_integer (port)
			end
		end

feature {NONE} -- Basic operations

	analyze
			-- Analyze address.
		local
			l_username: like username
			p: INTEGER
			s: STRING
		do
			Precursor
			l_username := username
			if l_username /= Void and then not l_username.is_empty then
				p := l_username.substring_index (";AUTH=", 1)
				if p > 0 then
					s := l_username.substring (p + 6, l_username.count)
					if s /= Void and then not s.is_empty then
						authentication := s.string
					end
					l_username.keep_head (p - 1)
					raw_url_decode (l_username)
				end
			end
		end

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
