indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SORTABLE_MULTI_COLUMN_LIST

inherit
	EV_MULTI_COLUMN_LIST
		redefine
			initialize, set_column_titles
		end

feature -- Init
	
	initialize is
			-- 
		do
			Precursor			
			column_title_click_actions.extend (agent select_column (?))
			create column_types.make (1, 5)
		end

feature -- Change

	set_column_titles (titles: ARRAY [STRING]) is
			-- Assign `titles' to titles of columns in order.
			-- `Current' will resize if the number of titles exceeds
			-- `Column_count'.
		do
			Precursor (titles)
			column_types.conservative_resize (titles.lower, titles.upper)
		end

	set_column_types (t: ARRAY [INTEGER]) is
		do
			column_types := t
		end

	set_column_type (a_type: INTEGER; a_column: INTEGER) is
		do
			column_types.put (a_type, a_column)
		end		

	select_column (c: INTEGER) is
		require
			c > 0
		local
			t: STRING
			p: STRING
		do
			if c /= selected_column then
				ascendant_sorting_order := True
			else
				ascendant_sorting_order := not ascendant_sorting_order
			end				
			p := selection_prefix
			if selected_column > 0 then
				t := column_title (selected_column)
				if 
					t.substring_index (selection_asc_prefix, 1) = 1 
					or else t.substring_index (selection_desc_prefix, 1) = 1
				then
					t.remove_substring (1, p.count)
					set_column_title (t, selected_column)
				end
			end
			selected_column := c
			set_column_title (p + column_title (selected_column), c)
			refresh
		end

	refresh is
		local
			l: DS_ARRAYED_LIST [COMPARABLE]
			h: DS_HASH_TABLE [like item , HASHABLE]
			r: like item
			ks: STRING
			kn: INTEGER_64
			kh: HASHABLE
			k: COMPARABLE
			type: INTEGER
		do
			hide
			create l.make (count)
			create h.make (count)
			type := column_types @ selected_column
--			if type = 0 then
--				type := cst_type_string
--			end
			from
				start
			until
				after
			loop
				r := item
				ks := r.i_th (selected_column) + index.out
				inspect type
				when cst_type_integer then
					kn := ks.to_integer_64
					k := kn
					kh := kn
					l.put_last (kn)
					h.force (r , kn)					
				else -- string, others ...
					if case_insensitive then
						ks.to_lower
					end
					k := ks
					kh := ks
					l.put_last (k)
					h.force (r , kh)					
				end
--				l.put_last (k)
--				h.force (r , kh)				
				forth
			end
			
			if ascendant_sorting_order then
				comparable_sorter.sort (l)
			else
				comparable_sorter.reverse_sort (l)
			end
			wipe_out
			from
				l.start
			until
				l.after
			loop
				kh ?= l.item_for_iteration
				r := h.item (kh)
				check
					r.parent = Void
				end
				extend (r)
				l.forth
			end
			show
		end

feature -- Access

	column_types: ARRAY [INTEGER]

	selected_column: INTEGER
	
	ascendant_sorting_order: BOOLEAN
	
	case_insensitive: BOOLEAN is True

feature -- constant

	cst_type_integer: INTEGER is unique
	cst_type_string: INTEGER is unique
	cst_type_date: INTEGER is unique
	
feature {NONE} -- Implementation


	selection_prefix: STRING is
		do
			if ascendant_sorting_order then
				Result := selection_asc_prefix
			else
				Result := selection_desc_prefix
			end
		end
		
	selection_asc_prefix: STRING is "[v] "
	
	selection_desc_prefix: STRING is "[^] "

	comparable_sorter: DS_SORTER [COMPARABLE] is
		local
			l_cmp: KL_COMPARABLE_COMPARATOR [COMPARABLE]
		once
			create l_cmp.make
			create {DS_QUICK_SORTER [COMPARABLE]} Result.make (l_cmp)
		end		

end -- class SORTABLE_MULTI_COLUMN_LIST
