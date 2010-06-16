note
	description: "Summary description for {CTR_LOGS_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CTR_LOGS_TOOL

inherit
	CTR_TOOL

	EV_SHARED_APPLICATION

create
	make

feature {NONE} -- Initialization

	build_interface (a_container: EV_CONTAINER)
		local
			g: like grid
			c: like sd_content
			mtb: SD_TOOL_BAR
			tbbut: SD_TOOL_BAR_BUTTON
		do
			create g
			grid := g

			a_container.extend (g)


			c := sd_content
--			g.enable_single_row_selection
			g.enable_multiple_row_selection
			g.enable_row_separators
			g.enable_column_separators
			g.set_separator_color (grid_separator_color)
			g.set_column_count_to (4)
			g.enable_partial_dynamic_content
			g.set_dynamic_content_function (agent on_logs_compute_grid_item (g, ?,?))
			g.column (cst_revision_column).set_title ("rev")
			g.column (cst_author_column).set_title ("author")
			g.column (cst_log_column).set_title ("message")
			g.column (cst_date_column).set_title ("date")
			c.set_short_title ("Logs ...")
			c.set_long_title ("Repository Logs ...")
			g.row_select_actions.extend (agent on_log_row_selected)
			g.pointer_double_press_item_actions.extend (agent on_log_item_double_clicked)
			create mtb.make
			create tbbut.make
			tbbut.set_pixmap (icons.new_check_small_toolbar_button_icon)
			tbbut.select_actions.extend (agent check_current_repository)
			mtb.extend (tbbut)
			mtb.compute_minimum_size
			c.set_mini_toolbar (mtb)

			g.key_press_actions.extend (agent on_key_pressed)
		end

feature -- Access

	filter: detachable REPOSITORY_LOG_FILTER

	current_log: detachable REPOSITORY_LOG

	current_repository: detachable REPOSITORY_DATA

	review_enabled: BOOLEAN

	grid: EV_GRID

feature -- Element change

	review_bar: detachable CTR_LOGS_REVIEW_BOX

	update_review_bar
		do
			if attached review_bar as r then
				r.update_current_log (current_log)
			end
		end

	build_review_bar
		local
			box: like review_bar
		do
			create box.make (Current)
			review_bar := box

			container.put_front (box.widget)
			container.disable_item_expand (box.widget)
		end

	show_review_bar
		do
			if review_bar = Void then
				build_review_bar
			end
			if attached review_bar as b then
				b.show
			end
		end

	hide_review_bar
		do
			if attached review_bar as b then
				b.hide
			end
		end

	update
		local
			g: like grid
			l_row: EV_GRID_ROW
			l_sorted_logs: ARRAYED_LIST [REPOSITORY_LOG]
			l_sorter: like log_sorter
			l_filter: like filter
		do
			if review_enabled then
				show_review_bar
			else
				hide_review_bar
			end
			g := grid
			g.set_row_count_to (0)
			if attached current_repository as rdata then
				rdata.load_logs
				if attached rdata.logs as l_logs then
					create l_sorted_logs.make (l_logs.count)
					l_filter := filter
					debug
						create {REPOSITORY_LOG_PATH_FILTER} l_filter.make ("/trunk/Src/C")
						create {REPOSITORY_LOG_AUTHOR_FILTER} l_filter.make ("jfiat")
					end

					across
						l_logs as c
					loop
						if l_filter /= Void then
							if l_filter.matched (c.item) then
								l_sorted_logs.force (c.item)
							end
						else
							l_sorted_logs.force (c.item)
						end
					end
					l_sorter := log_sorter
					l_sorter.reverse_sort (l_sorted_logs)
					across
						l_sorted_logs as c
					loop
						if attached c.item as l_log then
							g.insert_new_row (g.row_count + 1)
							l_row := g.row (g.row_count)
							l_row.set_data (l_log)
						end
					end
				end
			end
		end

	reset
		do
			current_log := Void
		end

	update_current_repository (a_repo: like current_repository)
		do
			if current_repository /= a_repo then
				current_repository := a_repo
				current_log := Void
			end
			review_enabled := a_repo /= Void and then a_repo.review_enabled
			update
		end

	check_current_repository
		do
			if attached ctr_window as w then
				if attached current_repository as r then
					w.check_repository (r)
				end
			end
		end

feature -- Basic operations

	update_log (a_log: REPOSITORY_LOG)
		local
			r,n: INTEGER
			g: like grid
			l_row: detachable EV_GRID_ROW
		do
			g := grid
			from
				r := 1
				n := g.row_count
			until
				r > n or l_row /= Void
			loop
				l_row := g.row (r)
				if l_row.data /= a_log then
					l_row := Void
				end
				r := r + 1
			end
			if l_row /= Void then

			end
		end

feature {CTR_WINDOW} -- Implementation

	request_update_logs_layout
		local
			l_update_logs_layout_action: like update_logs_layout_action
		do
			l_update_logs_layout_action := update_logs_layout_action
			if l_update_logs_layout_action = Void then
				create l_update_logs_layout_action.make (agent update_logs_layout, 100)
				update_logs_layout_action := l_update_logs_layout_action
			end
			l_update_logs_layout_action.request_call (Void)
		end

	update_logs_layout_action: detachable EV_DELAYED_ACTION_ARGS [detachable TUPLE]

	update_logs_layout
		local
			g: like grid
			w1, w: INTEGER
		do
			if attached update_logs_layout_action as d_act then
				d_act.cancel_request
				update_logs_layout_action := Void
			end

			w1 := 0
			g := grid
			if attached g.column (cst_revision_column) as col then
				col.set_width (col.required_width_of_item_span (1, g.row_count) + 4)
				w1 := w1 + col.width
			end
			if attached g.column (cst_date_column) as col then
				col.set_width (col.required_width_of_item_span (1, g.row_count) + 4)
				w1 := w1 + col.width
			end
			if attached g.column (cst_author_column) as col then
				col.set_width (col.required_width_of_item_span (1, g.row_count) + 4)
				w1 := w1 + col.width
			end
			if attached g.column (cst_log_column) as col then
				w := g.viewable_width
				col.set_width (w - w1 - g.vertical_scroll_bar.width)
			end
		end

	compute_row (a_log: REPOSITORY_LOG; a_row: EV_GRID_ROW)
		local
			glab_buts: EV_GRID_PIXMAPS_ON_RIGHT_LABEL_ITEM
			glab: EV_GRID_LABEL_ITEM
		do
			if a_log.has_review and then attached a_log.review as l_review then
				create glab_buts.make_with_text (a_log.id)
				glab_buts.set_pixmaps_on_right_count (1)
				glab_buts.put_pixmap_on_right (icons.action_review_icon, 1)
				a_row.set_item (cst_revision_column, glab_buts)
			else
				a_row.set_item (cst_revision_column, create {EV_GRID_LABEL_ITEM}.make_with_text (a_log.id))
			end
			create glab.make_with_text (a_log.single_line_message)
			a_row.set_item (cst_log_column, glab)
			a_row.set_item (cst_author_column, create {EV_GRID_LABEL_ITEM}.make_with_text (a_log.author))
			a_row.set_item (cst_date_column, create {EV_GRID_LABEL_ITEM}.make_with_text (a_log.date))

			if a_log.unread then
				mark_log_unread (a_row)
			end
		end

	on_logs_compute_grid_item (g: EV_GRID; c,r: INTEGER): EV_GRID_ITEM
		local
			gitem: detachable EV_GRID_ITEM
		do
			if attached g.row (r) as l_row then
				if attached {REPOSITORY_LOG} l_row.data as r_log then
					compute_row (r_log, l_row)
				end
				if l_row.count >= c then
					gitem := l_row.item (c)
				end
			end
			if gitem /= Void then
				Result := gitem
			else
				create Result
				g.set_item (c, r, Result)
			end
			request_update_logs_layout
		end

	on_log_row_selected (r: EV_GRID_ROW)
		local
			w: like ctr_window
		do
			if
				attached {REPOSITORY_LOG} r.data as rlog
			then
				rlog.mark_read
				mark_log_read (r)
				w := ctr_window
				if w /= Void then
					w.update_catalog_row_by_data (rlog.parent)
				end
				if
					current_log /= rlog and then
					grid.selected_rows.count <= 1
				then
					current_log := rlog
					update_review_bar
					if w /= Void then
						w.info_tool.update_current_log (rlog)
					end
				end
			end
		end

	on_key_pressed (a_key: EV_KEY)
		do
			inspect a_key.code
			when {EV_KEY_CONSTANTS}.key_delete then
				if ev_application.shift_pressed then
					delete_selected_row_logs
				end
			else

			end
		end

	on_log_item_double_clicked (a_x, a_y, a_but: INTEGER; a_cell: detachable EV_GRID_ITEM)
		do
			if a_cell /= Void and then attached a_cell.row as r then
				show_log_diff_from_row (r)
			end
		end

	show_log_diff_from_row (r: EV_GRID_ROW)
		do
			if attached {REPOSITORY_LOG} r.data as l_log then
				if current_log /= l_log then
					on_log_row_selected (r)
				end
				if attached ctr_window as w then
					w.show_log_diff (l_log)
				else
					print (l_log.diff)
				end
			end
		end

	delete_selected_row_logs
		local
		do
			if attached grid.selected_rows as l_rows and then l_rows.count > 0 then
				across
					l_rows as c
				loop
					if attached {REPOSITORY_LOG} c.item.data as l_log then
						c.item.disable_select
						l_log.delete
						c.item.hide
					end
				end
				current_log := Void
				if attached ctr_window as w then
					w.info_tool.update_current_repository (current_repository)
				end
			end
		end

	mark_log_unread (a_row: EV_GRID_ROW)
		local
			n,c: INTEGER
			ft: EV_FONT
		do
			n := a_row.count
			ft := font_unread_log
			from
				c := 1
			until
				c > n
			loop
				if attached {EV_GRID_LABEL_ITEM} a_row.item (c) as l_lab then
					l_lab.set_font (ft)
				end
				c := c + 1
			end
		end

	mark_log_read (a_row: EV_GRID_ROW)
		local
			n,c: INTEGER
			ft: EV_FONT
		do
			n := a_row.count
			ft := font_read_log
			from
				c := 1
			until
				c > n
			loop
				if attached {EV_GRID_LABEL_ITEM} a_row.item (c) as l_lab then
					l_lab.set_font (ft)
				end
				c := c + 1
			end
		end

	log_sorter: QUICK_SORTER [REPOSITORY_LOG]
		once
			create Result.make (create {COMPARABLE_COMPARATOR [REPOSITORY_LOG]})
		end

feature {NONE} -- Constants

	cst_revision_column: INTEGER = 1
	cst_date_column: INTEGER = 2
	cst_author_column: INTEGER = 3
	cst_log_column: INTEGER = 4


end
