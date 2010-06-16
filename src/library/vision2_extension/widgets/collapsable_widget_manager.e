indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COLLAPSABLE_WIDGET_MANAGER

inherit
	EV_SHARED_APPLICATION

create
	make

feature -- Access

	wrapper_widget: EV_WIDGET

	inside_widget: EV_WIDGET

feature {NONE} -- Impl

	is_vertical: BOOLEAN

	is_horizontal: BOOLEAN is
		do
			Result := not is_vertical
		end

	bar: EV_BOX

	split_bar: EV_CELL

	box: EV_BOX
	inner_box: EV_CELL

	pixmap: EV_PIXMAP

feature -- Constant

	Position_top: INTEGER is 1
	Position_right: INTEGER is 2
	Position_bottom: INTEGER is 3
	Position_left: INTEGER is 4

feature {NONE} -- Creation

	make (a_widget: EV_WIDGET; a_position: INTEGER; a_bar_width: INTEGER) is
		do
			inside_widget := a_widget
			normal_background_color := inside_widget.background_color.twin

			create split_bar

			inspect a_position
			when Position_top, Position_bottom then
				is_vertical := False
				create {EV_VERTICAL_BOX} box
				create {EV_HORIZONTAL_BOX} bar
				split_bar.set_minimum_height (2)
			when Position_left, Position_right then
				is_vertical := True
				create {EV_HORIZONTAL_BOX} box
				create {EV_VERTICAL_BOX} bar
				split_bar.set_minimum_width (2)
			else
				check False end
			end

			split_bar.hide
			box.set_border_width (1)
			wrapper_widget := box

			set_background_color (normal_background_color)

			pixmap := new_divider_pixmap (a_bar_width, 50)

			bar.extend (create {EV_CELL})
			bar.extend (pixmap)
			pixmap.set_minimum_size (pixmap.width, pixmap.height)
			bar.disable_item_expand (pixmap)
			bar.extend (create {EV_CELL})
			bar.propagate_background_color

			create inner_box
			inner_box.set_background_color (inside_widget.background_color)
			inner_box.extend (inside_widget)

			box.extend (inner_box)
			inspect a_position
			when Position_top, Position_left then
				box.put_front (bar)
				box.extend (split_bar)
			when Position_bottom, Position_right then
				box.extend (bar)
				box.put_front (split_bar)
			else
				check False end
			end
			box.disable_item_expand (bar)
			box.disable_item_expand (split_bar)


			pixmap.pointer_button_release_actions.force_extend (agent toggle_widget)
--			pixmap.pointer_double_press_actions.force_extend (agent toggle_split)

			bar.pointer_enter_actions.extend (agent on_mouse_over_enter)
			bar.pointer_leave_actions.extend (agent on_mouse_over_exit)

			pixmap.pointer_enter_actions.extend (agent on_mouse_over_enter)
			pixmap.pointer_leave_actions.extend (agent on_mouse_over_exit)
		end

feature -- Change

	set_border_width (v: INTEGER) is
		do
			box.set_border_width (v)
		end

	set_background_color (v: EV_COLOR) is
		do
			normal_background_color := v.twin
			box.set_background_color (normal_background_color)
			bar.set_background_color (normal_background_color)
			bar.propagate_background_color
			split_bar.set_background_color (normal_background_color)
			update_divider_pixmap
			init_hover_background_color
		end

	set_foreground_color (v: EV_COLOR) is
		do
			bar.set_foreground_color (v)
			bar.propagate_foreground_color
			update_divider_pixmap
		end

	normal_background_color: EV_COLOR
	hover_background_color: EV_COLOR

	on_mouse_over_enter is
		do
			box.set_background_color (hover_background_color)
			bar.set_background_color (hover_background_color)
			bar.propagate_background_color
			bar.refresh_now

			split_bar.set_background_color (hover_background_color)
			split_bar.refresh_now

			update_divider_pixmap
		end

	on_mouse_over_exit is
		do
			box.set_background_color (normal_background_color)
			bar.set_background_color (normal_background_color)
			bar.propagate_background_color
			bar.refresh_now

			split_bar.set_background_color (normal_background_color)
			split_bar.refresh_now

			update_divider_pixmap
		end

	toggle_widget is
		do
			if inside_widget.is_displayed then
				inner_box.hide
				split_bar.hide
			else
				split_bar.show
				inner_box.show
			end
		end

	update_divider_pixmap is
		do
			if pixmap /= Void then
				if is_vertical then
					update_vertical_divider_pixmap (pixmap)
				else
					update_horizontal_divider_pixmap (pixmap)
				end
			end
		end

	new_divider_pixmap (a_small_side_size, a_long_side_size: INTEGER): EV_PIXMAP is
		require
			a_long_side_size > 15
			inside_widget /= Void
		do
			if is_vertical then
				create Result.make_with_size (a_small_side_size, a_long_side_size)
				update_vertical_divider_pixmap (Result)
			else
				create Result.make_with_size (a_long_side_size, a_small_side_size)
				update_horizontal_divider_pixmap (Result)
			end
		end

	update_vertical_divider_pixmap (pix: EV_PIXMAP) is
		local
			w,h: INTEGER
			fgcolor, bgcolor: EV_COLOR
			i: INTEGER
			o: INTEGER
		do
			w := pix.width
			h := pix.height

			o := w - 3 - 1 // 2

			create fgcolor.make_with_8_bit_rgb (0,0,0)
			bgcolor := bar.background_color

			pix.set_foreground_color (bgcolor)
			pix.set_background_color (bgcolor)
			pix.clear
			pix.set_foreground_color (fgcolor)
			pix.set_background_color (bgcolor)

			pix.draw_point (o+0,0);                                                 	   	--			#
			pix.draw_point (o+0,1); 	pix.draw_point (o+1,1);                           	--			##
			pix.draw_point (o+0,2); 	pix.draw_point (o+1,2);	pix.draw_point (o+2,2);   	--			###
			pix.draw_point (o+0,3); 	pix.draw_point (o+1,3);                           	--			##
			pix.draw_point (o+0,4)                                                    		--			#

            from
            	i := 7
            until
            	i > h - 7
            loop
				pix.draw_point (o+1, i)
            	i := i + 2
            end
																	pix.draw_point (o+2,h-5)   	--			  #
							 			pix.draw_point (o+1,h-4);	pix.draw_point (o+2,h-4);  	--			 ##
			pix.draw_point (o+0,h-3);	pix.draw_point (o+1,h-3);	pix.draw_point (o+2,h-3);  	--			###
										pix.draw_point (o+1,h-2);	pix.draw_point (o+2,h-2);  	--			 ##
																	pix.draw_point (o+2,h-1)   	--			  #
		end

	update_horizontal_divider_pixmap (pix: EV_PIXMAP) is
		local
			w,h: INTEGER
			fgcolor, bgcolor: EV_COLOR
			i: INTEGER
			o: INTEGER
		do
			w := pix.width
			h := pix.height

			o := h - 3 - 1 // 2


			create fgcolor.make_with_8_bit_rgb (0,0,0)
			bgcolor := bar.background_color
			pix.set_foreground_color (bgcolor)
			pix.set_background_color (bgcolor)
			pix.clear
			pix.set_foreground_color (fgcolor)
			pix.set_background_color (bgcolor)

			pix.draw_point (0,o+0)                                                    		--			#
			pix.draw_point (1,o+0); 	pix.draw_point (1,o+1);                           	--			##
			pix.draw_point (2,o+0); 	pix.draw_point (2,o+1);	pix.draw_point (2,o+2);   	--			###
			pix.draw_point (3,o+0); 	pix.draw_point (3,o+1);                           	--			##
			pix.draw_point (4,o+0)                                                  	  	--			#

            from
            	i := 7
            until
            	i > w - 7
            loop
				pix.draw_point (i, o+1)
            	i := i + 2
            end
																	pix.draw_point (w-5,o+2)   	--			  #
										pix.draw_point (w-4,o+1);	pix.draw_point (w-4,o+2);  	--			 ##
			pix.draw_point (w-3,o+0);	pix.draw_point (w-3,o+1);	pix.draw_point (w-3,o+2);  	--			###
										pix.draw_point (w-2,o+1);	pix.draw_point (w-2,o+2);  	--			 ##
																	pix.draw_point (w-1,o+2)   	--			  #
		end

feature -- resizing

	resize_cursor: EV_CURSOR

	resize_min, resize_max: INTEGER

	enable_resize (min, max: INTEGER) is
		require
			min > 0
			max > 0
		local
			stock: EV_STOCK_PIXMAPS
		do
			resize_min := min
			resize_max := max
			split_bar.show

			create stock
			if is_vertical then
				resize_cursor := stock.sizewe_cursor
			else
				resize_cursor := stock.sizens_cursor
			end
			split_bar.pointer_enter_actions.extend (agent on_mouse_over_split_enter)
			split_bar.pointer_leave_actions.extend (agent on_mouse_over_split_exit)

			split_bar.pointer_button_press_actions.extend (agent on_resize_start)
		ensure
			resize_min = min
			resize_max = max
		end

	disable_resize is
		do
			split_bar.hide
			split_bar.pointer_enter_actions.wipe_out
			split_bar.pointer_leave_actions.wipe_out
			split_bar.pointer_button_press_actions.wipe_out
		end

	on_mouse_over_split_enter is
		do
			split_bar.set_pointer_style (resize_cursor)
		end

	on_mouse_over_split_exit is
		do
			if not is_resizing then
				split_bar.set_pointer_style (box.pointer_style)
			end
		end

	is_resizing: BOOLEAN
	initial_x, initial_y: INTEGER
	on_resize_motion_agent: PROCEDURE [ANY, TUPLE [EV_WIDGET, INTEGER, INTEGER]]
	on_resize_completed_agent: PROCEDURE [ANY, TUPLE [EV_WIDGET, INTEGER, INTEGER, INTEGER]]

	on_resize_start (a_x, a_y, a_button: INTEGER; a_x_tilt, a_y_tilt, a_pressure: DOUBLE; a_screen_x, a_screen_y: INTEGER) is
		do
			if a_button = 1 then
				on_resize_motion_agent := agent on_resize_motion
				ev_application.pointer_motion_actions.extend (on_resize_motion_agent)
				on_resize_completed_agent := agent on_resize_completed
				ev_application.pointer_button_release_actions.extend (on_resize_completed_agent)
				initial_x := a_screen_x
				initial_y := a_screen_y
				is_resizing := True
				update_pointer_style
			end
		end

	on_resize_motion (a_widget: EV_WIDGET; a_screen_x, a_screen_y: INTEGER) is
		local
			v: INTEGER
		do
			if is_resizing then
				if is_vertical and (a_screen_x - initial_x).abs > 3 then
					v := inner_box.width + initial_x - a_screen_x
					if v <= resize_min then
						v := resize_min
						initial_x  := resize_min - inner_box.width + a_screen_x
						stop_resizing
					elseif v >= resize_max then
						v := resize_max
						initial_x  := resize_max - inner_box.width + a_screen_x
						stop_resizing
					else
						initial_x := a_screen_x
					end
					inner_box.set_minimum_width (v)
				elseif is_horizontal and (a_screen_y - initial_y).abs > 3 then
					v := inner_box.height + initial_y - a_screen_y
					if v <= resize_min then
						v := resize_min
						initial_y := resize_min - inner_box.height + a_screen_y
						stop_resizing
					elseif v >= resize_max then
						v := resize_max
						initial_y := resize_max - inner_box.height + a_screen_y
						stop_resizing
					else
						initial_y := a_screen_y
					end
					inner_box.set_minimum_height (v)
				end
			end
		end

	on_resize_completed (a_widget: EV_WIDGET; a_button, a_screen_x, a_screen_y: INTEGER) is
		do
			stop_resizing
		end

	stop_resizing is
		do
			is_resizing := False
			ev_application.pointer_motion_actions.prune_all (on_resize_motion_agent)
			ev_application.pointer_button_release_actions.prune_all (on_resize_completed_agent)
			on_resize_motion_agent := Void
			update_pointer_style
		end

	orig_cursor: EV_CURSOR

	update_pointer_style is
		local
			win: EV_WINDOW
		do
			win := parent_window (wrapper_widget)
			if win /= Void then
				if is_resizing then
					orig_cursor := win.pointer_style
					win.set_pointer_style (resize_cursor)
				elseif orig_cursor /= Void then

					win.set_pointer_style (orig_cursor)
					orig_cursor := Void
				end
			end
		end

	parent_window (w: EV_WIDGET): EV_WINDOW is
			-- `Result' is window parent of `widget'.
			-- `Void' if none.
		require
			widget_not_void: w /= Void
		local
			win: EV_WINDOW
		do
			win ?= w.parent
			if win = Void then
				if w.parent /= Void then
					Result := parent_window (w.parent)
				end
			else
				Result := win
			end
		end

feature -- access

	init_hover_background_color is
		do
			if not hover_background_color_set then
				hover_background_color := normal_background_color.twin
				if hover_background_color.blue > 0.5 then
					hover_background_color.set_blue ((1 - hover_background_color.blue / 2))
				else
					hover_background_color.set_blue (hover_background_color.blue)
				end
				if hover_background_color.red > 0.5 then
					hover_background_color.set_red ((1 - hover_background_color.red / 2))
				else
					hover_background_color.set_red (hover_background_color.red)
				end
				if hover_background_color.green > 0.5 then
					hover_background_color.set_green ((1 - hover_background_color.green / 2))
				else
					hover_background_color.set_green (hover_background_color.green)
				end
			end
		end

	hover_background_color_set: BOOLEAN

	set_hover_background_color (v: like hover_background_color) is
		do
			if v /= Void then
				hover_background_color_set := True
				hover_background_color := v
			else
				hover_background_color_set := False
				init_hover_background_color
			end
		end

end
