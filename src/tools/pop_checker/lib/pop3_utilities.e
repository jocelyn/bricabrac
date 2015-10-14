note
	description: "Summary description for {POP3_UTILITIES}."
	author: ""
	date: "$Date: 2009-06-18 18:23:06 +0200 (Thu, 18 Jun 2009) $"
	revision: "$Revision: 38 $"

class
	POP3_UTILITIES

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

feature -- Encoder base64

	base64_encoded (s: STRING): STRING_8
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
					create f.make_empty (8 * n + (6 - i))
				else
					create f.make_empty (8 * n)
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

end
