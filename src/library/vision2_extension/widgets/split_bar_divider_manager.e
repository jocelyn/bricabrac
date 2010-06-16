indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SPLIT_BAR_DIVIDER_MANAGER

create
	make

feature {NONE} -- Creation

	make (a_index: INTEGER; a_split: EV_SPLIT_AREA) is
		require
			a_index_valid: a_index = 1 or a_index = 2
			a_split.count = 2
		local
			hsplit: EV_HORIZONTAL_SPLIT_AREA
			box: EV_BOX
			w: EV_WIDGET
			pix: EV_PIXMAP
			is_horizontal: BOOLEAN
		do
			split := a_split
			hsplit ?= split
			if hsplit /= Void then
				is_horizontal := True
			end

			split_position := split.split_position

			if is_horizontal then
				create {EV_VERTICAL_BOX} split_bar
				split_bar.set_minimum_width (5)
				pix := new_vertical_divider_pixmap (5, 50)
			else
				create {EV_HORIZONTAL_BOX} split_bar
				split_bar.set_minimum_height (5)
				pix := new_horizontal_divider_pixmap (50, 5)
			end

			split_bar.extend (create {EV_CELL})
			split_bar.extend (pix)
			pix.set_minimum_size (pix.width, pix.height)
			split_bar.disable_item_expand (pix)
			split_bar.extend (create {EV_CELL})

			if is_horizontal then
				create {EV_HORIZONTAL_BOX} box
			else
				create {EV_VERTICAL_BOX} box
			end

			box.extend (split_bar)
			box.disable_item_expand (split_bar)

			if split.parent /= Void then
				box.set_background_color (split.parent.background_color)
			else
				box.set_background_color (split.background_color)
			end
			box.propagate_background_color

			if a_index = 1 then
				w := a_split.first
				split.go_to_first
				split.replace (box)
				box.extend (w)
			else
				w := split.second
				split.go_to_second
				split.replace (box)
				box.put_front (w)
			end

			normal_background_color := split_bar.background_color.twin
			hover_background_color := normal_background_color.twin -- pix.foreground_color.twin
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


			pix.pointer_button_release_actions.force_extend (agent toggle_split)
--			pix.pointer_double_press_actions.force_extend (agent toggle_split)
			pix.pointer_enter_actions.extend (agent on_mouse_over_enter)
			pix.pointer_leave_actions.extend (agent on_mouse_over_exit)
		end

	normal_background_color: EV_COLOR
	hover_background_color: EV_COLOR

	on_mouse_over_enter is
		do
			split_bar.set_background_color (hover_background_color)
			split_bar.propagate_background_color
		end

	on_mouse_over_exit is
		do
			split_bar.set_background_color (normal_background_color)
			split_bar.propagate_background_color
		end

	toggle_split is
		require
			split.count = 2
		local
			w: EV_WIDGET
			b: EV_BOX
		do
			b ?= split_bar.parent
			if split.first.is_displayed and split.second.is_displayed then
					-- opened
				split_position := split.split_position

				if split.first = b then
					w := b.i_th (2)
					b.prune (w)
					b.disable_item_expand (split_bar)

					split.go_to_first
					split.replace (w)
					w.hide

					w := split.second
					split.go_to_second
					split.replace (b)
					b.extend (w)
				else
					check split.second = b end
					w := b.i_th (1)
					b.prune (w)
					b.disable_item_expand (split_bar)
					split.go_to_second
					split.replace (w)
					w.hide

					w := split.first
					split.go_to_first
					split.replace (b)
					b.put_front (w)
				end
			else
				if split.first.is_displayed then
					check b = split.first end
					w := b.i_th (1)
					b.prune (w)
					b.disable_item_expand (split_bar)

					split.go_to_first
					split.replace (w)

					w := split.second
					split.go_to_second
					split.replace (b)
					b.put_front (w)
					w.show
				else
					check split.second.is_displayed end
					check b = split.second end
					w := b.i_th (2)
					b.prune (w)
					b.disable_item_expand (split_bar)

					split.go_to_second
					split.replace (w)

					w := split.first
					split.go_to_first
					split.replace (b)
					b.extend (w)
					w.show
				end
				split.set_split_position (split_position)
			end
		end

	new_vertical_divider_pixmap (w, h: INTEGER): EV_PIXMAP is
		require
			h > 15
			split /= Void
		local
			pix: EV_PIXMAP
			fgcolor, bgcolor: EV_COLOR
			i: INTEGER
		do
			create pix.make_with_size (3, h)  --  w instead of 3 ...
			create fgcolor.make_with_8_bit_rgb (0,0,0)
			if split.parent /= Void then
				bgcolor := split.parent.background_color
			else
				bgcolor := split.background_color
			end
			pix.set_foreground_color (bgcolor)
			pix.set_background_color (bgcolor)
			pix.clear
			pix.set_foreground_color (fgcolor)
			pix.set_background_color (bgcolor)

			pix.draw_point (0,0)                                                    	--			#
			pix.draw_point (0,1); 	pix.draw_point (1,1);                           	--			##
			pix.draw_point (0,2); 	pix.draw_point (1,2);	pix.draw_point (2,2);   	--			###
			pix.draw_point (0,3); 	pix.draw_point (1,3);                           	--			##
			pix.draw_point (0,4)                                                    	--			#

            from
            	i := 7
            until
            	i > h - 7
            loop
				pix.draw_point (1, i)
            	i := i + 2
            end
															pix.draw_point (2,h-5)   	--			  #
									pix.draw_point (1,h-4);	pix.draw_point (2,h-4);  	--			 ##
			pix.draw_point (0,h-3);	pix.draw_point (1,h-3);	pix.draw_point (2,h-3);  	--			###
									pix.draw_point (1,h-2);	pix.draw_point (2,h-2);  	--			 ##
															pix.draw_point (2,h-1)   	--			  #
			Result := pix
		end

	new_horizontal_divider_pixmap (w, h: INTEGER): EV_PIXMAP is
		require
			w > 15
			split /= Void
		local
			pix: EV_PIXMAP
			fgcolor, bgcolor: EV_COLOR
			i: INTEGER
		do
			create pix.make_with_size (w, 3)  --  h instead of 3 ...
			create fgcolor.make_with_8_bit_rgb (0,0,0)
			if split.parent /= Void then
				bgcolor := split.parent.background_color
			else
				bgcolor := split.background_color
			end
			pix.set_foreground_color (bgcolor)
			pix.set_background_color (bgcolor)
			pix.clear
			pix.set_foreground_color (fgcolor)
			pix.set_background_color (bgcolor)

			pix.draw_point (0,0)                                                    	--			#
			pix.draw_point (1,0); 	pix.draw_point (1,1);                           	--			##
			pix.draw_point (2,0); 	pix.draw_point (2,1);	pix.draw_point (2,2);   	--			###
			pix.draw_point (3,0); 	pix.draw_point (3,1);                           	--			##
			pix.draw_point (4,0)                                                    	--			#

            from
            	i := 7
            until
            	i > w - 7
            loop
				pix.draw_point (i, 1)
            	i := i + 2
            end
															pix.draw_point (w-5,2)   	--			  #
									pix.draw_point (w-4,1);	pix.draw_point (w-4,2);  	--			 ##
			pix.draw_point (w-3,0);	pix.draw_point (w-3,1);	pix.draw_point (w-3,2);  	--			###
									pix.draw_point (w-2,1);	pix.draw_point (w-2,2);  	--			 ##
															pix.draw_point (w-1,2)   	--			  #
			Result := pix
		end

feature {NONE} -- Impl

	split: EV_SPLIT_AREA

	split_position: INTEGER

	split_bar: EV_BOX

feature -- access

	activate is
		do
			toggle_split
		end

	set_hover_background_color (v: like hover_background_color) is
		do
			hover_background_color := v
		end

end
