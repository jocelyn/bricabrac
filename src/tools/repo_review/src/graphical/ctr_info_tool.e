note
	description: "Summary description for {CTR_LOGS_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CTR_INFO_TOOL

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

			g.enable_single_row_selection
			g.set_column_count_to (2)
			g.disable_row_height_fixed
			g.enable_tree
			g.hide_header
			c.set_short_title ("Info ...")
			c.set_long_title ("Info")
			create mtb.make
			create tbbut.make
			tbbut.set_pixmap (icons.new_diff_small_toolbar_button_icon)
			tbbut.select_actions.extend (agent show_info_diff)
			mtb.extend (tbbut)

			create tbbut.make
			tbbut.set_pixmap (icons.new_custom_text_small_toolbar_button_icon ("Open Data Folder"))
			tbbut.select_actions.extend (agent open_data_folder)
			mtb.extend (tbbut)

			mtb.compute_minimum_size
			c.set_mini_toolbar (mtb)
		end

feature -- Access

	current_log: detachable REPOSITORY_LOG

	current_repository: detachable REPOSITORY_DATA

	grid: EV_GRID

feature -- Element change

	update
		local
			g: like grid
			l_row, l_subrow: EV_GRID_ROW
			glab: EV_GRID_LABEL_ITEM
			grtxt: EV_GRID_RICH_LABEL_ITEM
			gcb: EV_GRID_CHECKABLE_LABEL_ITEM
			gtxt: EV_GRID_TEXT_ITEM
		do
			g := grid
			g.wipe_out
			if attached {REPOSITORY_SVN_LOG} current_log as rsvnlog then
				g.insert_new_row (g.row_count + 1)
				l_row := g.row (g.row_count)
				l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Info"))
				create grtxt--.make_with_text ("revision " + rsvnlog.id + " by " + rsvnlog.author + " (" + rsvnlog.date + ")")
				grtxt.add_formatted_text ("revision ", Void, Void)
				grtxt.add_formatted_text (rsvnlog.id, info_highlight_fgcolor, font_bold)
				grtxt.add_formatted_text (" by ", Void, Void)
				grtxt.add_formatted_text (rsvnlog.author, info_highlight_fgcolor, font_bold)
				grtxt.add_formatted_text (" (" + rsvnlog.date + ")", Void, font_comment)


				l_row.set_item (2, grtxt)

				g.insert_new_row (g.row_count + 1)
				l_row := g.row (g.row_count)
				create glab.make_with_text ("Message")
				glab.align_text_top
				l_row.set_item (1, glab)
				create glab.make_with_text (rsvnlog.message)
				glab.set_foreground_color (info_highlight_fgcolor)
				glab.set_font (message_font)
				l_row.set_item (2, glab)
				if attached glab.font as ft then
					l_row.set_height (ft.string_size (glab.text).height)
				end

				if attached rsvnlog.svn_revision.paths as l_changes and then l_changes.count > 0 then
					g.insert_new_row (g.row_count + 1)
					l_row := g.row (g.row_count)
					if l_changes.count = 1 then
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("1 node changed"))
					else
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text (l_changes.count.out + " nodes changed"))
					end
					l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (rsvnlog.svn_revision.common_parent_path + " ..."))
					l_row.expand_actions.extend (agent do changes_expanded := True end)
					l_row.collapse_actions.extend (agent do changes_expanded := False end)

					across
						l_changes as l_paths
					loop
						g.insert_new_row_parented (g.row_count + 1, l_row)
						l_subrow := g.row (g.row_count)
						l_subrow.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text (l_paths.item.action))
						l_subrow.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_paths.item.path))
					end
					if l_row.is_expandable and changes_expanded then
						l_row.expand
					end
				end


				g.insert_new_row (g.row_count + 1)
				l_row := g.row (g.row_count)
				l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Diff"))

				if rsvnlog.has_diff then
					create glab.make_with_text ("Double click to SHOW diff")
					glab.pointer_double_press_actions.force_extend (agent popup_diff (rsvnlog))
					l_row.set_item (2, glab)
				else
					create glab.make_with_text ("Double click to GET diff")
					glab.pointer_double_press_actions.force_extend (agent show_info_diff)
					l_row.set_item (2, glab)
				end

				if rsvnlog.parent.review_enabled then
					g.insert_new_row (g.row_count + 1)
					l_row := g.row (g.row_count)
					l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Review"))
					l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text ("???"))

					g.insert_new_row_parented (g.row_count + 1, l_row)
					l_subrow := g.row (g.row_count)
					l_subrow.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Accept"))
					create gcb.make_with_text ("approve commit")
					l_subrow.set_item (2, gcb)

					g.insert_new_row_parented (g.row_count + 1, l_row)
					l_subrow := g.row (g.row_count)
					l_subrow.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Deny"))
					create gcb.make_with_text ("disapprove commit")
					l_subrow.set_item (2, gcb)


					g.insert_new_row_parented (g.row_count + 1, l_row)
					l_subrow := g.row (g.row_count)
					l_subrow.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Note"))
					create gtxt.make_with_text ("")
					gtxt.enable_multiline_string
					gtxt.enable_text_editing
					gtxt.pointer_double_press_actions.force_extend (agent gtxt.activate)
					l_subrow.set_item (2, gtxt)

					g.insert_new_row_parented (g.row_count + 1, l_row)
					l_subrow := g.row (g.row_count)
					l_subrow.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Reset"))
					l_subrow.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text ("Submit"))
				end

				g.column (1).resize_to_content
				g.column (1).set_width (g.column (1).width + 5)
				g.column (2).resize_to_content
			elseif attached {REPOSITORY_SVN_DATA} current_repository as rsvnrepo then
				if attached rsvnrepo.info as rinfo then
					g.insert_new_row (g.row_count + 1)
					l_row := g.row (g.row_count)
					l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Revision"))
					l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (rinfo.revision.out))

					g.insert_new_row (g.row_count + 1)
					l_row := g.row (g.row_count)
					l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Localisation"))
					l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (rinfo.localisation))

					if attached rinfo.last_changed_rev as l_rev then
						g.insert_new_row (g.row_count + 1)
						l_row := g.row (g.row_count)
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Last rev"))
						l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_rev.out))
					end
					if attached rinfo.last_changed_author as l_author then
						g.insert_new_row (g.row_count + 1)
						l_row := g.row (g.row_count)
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Last author"))
						l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_author))
					end
					if attached rinfo.last_changed_date as l_date then
						g.insert_new_row (g.row_count + 1)
						l_row := g.row (g.row_count)
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Last Date"))
						l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_date))
					end

					if attached rinfo.repository_root as l_root then
						g.insert_new_row (g.row_count + 1)
						l_row := g.row (g.row_count)
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Repo Root"))
						l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_root))
					end

					if attached rinfo.repository_uuid as l_uuid then
						g.insert_new_row (g.row_count + 1)
						l_row := g.row (g.row_count)
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Repo UUID"))
						l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_uuid))
					end

					if attached rinfo.url as l_url then
						g.insert_new_row (g.row_count + 1)
						l_row := g.row (g.row_count)
						l_row.set_item (1, create {EV_GRID_LABEL_ITEM}.make_with_text ("Url"))
						l_row.set_item (2, create {EV_GRID_LABEL_ITEM}.make_with_text (l_url))
					end

					g.column (1).resize_to_content
					g.column (1).set_width (g.column (1).width + 5)
					g.column (2).resize_to_content
				end
			end
		end


	update_current_log (v: like current_log)
		do
			current_repository := Void
			current_log := v
			update
		end

	update_current_repository (v: like current_repository)
		do
			current_log := Void
			current_repository := v
			update
		end

feature {NONE} -- Implementation

	open_data_folder
		local
			exec: EXECUTION_ENVIRONMENT
			s: detachable STRING
		do
			if attached current_repository as r then
				s := r.data_folder_name
			elseif attached current_log as l_log then
				s := l_log.parent.data_folder_name
			end
			if s /= Void then
				create exec
				if attached exec.get ("COMSPEC") as l_comspec then
					s := l_comspec + " /C start " + s
				else
					s := "explorer " + s
				end
				exec.launch (s)
			end
		end

	popup_diff (a_log: REPOSITORY_LOG)
		do
			if attached ctr_window as w then
				w.popup_diff (a_log)
			end
		end

	show_info_diff
		do
			if attached ctr_window as w then
				if attached current_log as l_log then
					w.show_log_diff (l_log)
				end
			end
		end

	changes_expanded: BOOLEAN


end
