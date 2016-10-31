indexing
	description: "Objects that ..."
	author: ""
	date: "$Date: 2007-08-29 17:44:41 +0200 (Wed, 29 Aug 2007) $"
	revision: "$Revision: 370 $"

class
	MBOX_MESSAGE

create
	make,
	make_empty

feature

	make_empty is
		do

		end

	make (h: STRING_GENERAL; b: STRING_GENERAL) is
			--
		do
			make_empty
			set_header (h)
			set_body (b)
		end

	set_header (h: STRING_GENERAL) is
		do
			header_items := string_to_header_items (h)
		end

	set_body (b: STRING_GENERAL) is
		do
			body := b
		end

	reset_values is
			--
		do
			from_line := Void
			date_value := Void
			subject_value := Void
			reply_to_value := Void
		end

	from_line: STRING_32
	date_value: STRING_32
	subject_value: STRING_32
	reply_to_value: STRING_32

	header_items: ARRAYED_LIST [TUPLE [name: STRING_32; value: STRING_32]]

	body: STRING_32

	string_to_header_items (h: STRING_GENERAL): like header_items is
			--
		local
			p, pn, pc: INTEGER
			l: STRING_32
			nl_code, colon_code: NATURAL_32
			n,v: STRING_32
		do
			create Result.make (3)
			reset_values
			from
				nl_code := ('%N').natural_32_code
				colon_code := (':').natural_32_code
				p := 1
				l := ""
			until
				l = Void or p >= h.count
			loop
				pn := h.index_of_code (nl_code, p)
				if pn > 0 then
					l := h.substring (p, pn - 1)
				else
					l := h.substring (p, h.count)
				end
				if l /= Void then
					if from_line = Void then
						from_line := l
					else
						pc := l.index_of_code (colon_code, 1)
						if pc > 0 then
							n := l.substring (1, pc - 1)
							v := l.substring (pc + 1 , l.count)
							Result.force ([n, v])
							if date_value = Void and then n.is_case_insensitive_equal ("date") then
								date_value := v
							elseif subject_value = Void and then n.is_case_insensitive_equal ("subject") then
								subject_value := v
							elseif reply_to_value = Void and then n.is_case_insensitive_equal ("reply-to") then
								reply_to_value := v
							end
						elseif Result.last.value /= Void then
							Result.last.value.append (l)
						end
					end
					p := pn + 1
				end
			end
		end

	header_value (n: STRING_GENERAL): STRING_32 is
			--
		require
			n_not_void: n /= Void
		local
			k32: STRING_32
			lst: like header_items
			t: TUPLE [n: STRING_32; v: STRING_32]
		do
			k32 := n.as_string_32.as_lower
			lst := header_items
			if lst /= Void then
				from
					lst.start
				until
					lst.after or Result /= Void
				loop
					t := lst.item
					if t /= Void and then t.n.is_case_insensitive_equal (k32) then
						Result := t.v
					end
					lst.forth
				end
			end
		end

end
