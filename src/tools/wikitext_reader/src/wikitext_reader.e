note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	WIKITEXT_READER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			l_include_in_system: TUPLE [WIKI_NULL_VISITOR]
		do
--			read_folder ("tests\eiffelstudio", "EiffelStudio")
			read_folder ("tests\test", "Test")
--			read_folder ("tests\community", "Community")			
		end

	read_folder (a_dir: STRING; a_name: STRING)
		local
			f: RAW_FILE
			fn: FILE_NAME
			s, t, k: STRING
			ln, p: INTEGER
			wb: detachable WIKI_BOOK
			pwp, wp: detachable WIKI_PAGE
		do
			create fn.make_from_string (a_dir)
			fn.set_file_name ("book.index")
			create f.make (fn.string)
			if f.exists and f.is_readable then
				create wb.make (a_name, a_dir)
				f.open_read
				from
					ln := 0
				until
					f.exhausted or f.end_of_file
				loop
					f.read_line
					s := f.last_string
					ln := ln + 1
					s.left_adjust
					if s.is_empty then
						-- skip
					elseif s.item (1) = '[' then
						pwp := wp
						wp := Void
						p := s.index_of (']', 2)
						if p > 0 then
							t := s.substring (p + 1, s.count)
							s := s.substring (2, p - 1)
							if attached s.split (':') as lst and then lst.count >= 3 then
								lst.start
								lst.forth
								k := lst.item
								create wp.make (t, k)
								wb.add_page (wp)
							end
						else
							-- skip
							print ("Error page line " + ln.out + "[" + s + "]%N")
						end
--						if wp /= Void then
--							pwp.add_page (wp)
--						end
					elseif s.substring (1, 5) ~ "!src=" then
						if wp /= Void then
							wp.set_src (s.substring (6, s.count))
						end
					else
						-- skip
						print ("Error line " + ln.out + "[" + s + "]%N")
					end
--					[0:book:-9] EiffelStudio
--					 !src=eiffelstudio/index
				end
				f.close
			end
			if
				wb /= Void and then
				attached wb.pages as l_pages
			then
				from
					l_pages.start
				until
					l_pages.after
				loop
					l_pages.item.get_structure (wb)
					l_pages.forth
				end
			end
		end

feature -- Status

feature -- Access

feature -- Change

feature {NONE} -- Implementation

invariant
--	invariant_clause: True

end
