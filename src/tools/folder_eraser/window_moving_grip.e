indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WINDOW_MOVING_GRIP

inherit
	EV_SHARED_APPLICATION

create
	make

feature -- Initialization

	make (wid: like widget; win: like window) is
			--
		do
			widget := wid
			window := win
		end

feature -- Access

	widget: EV_WIDGET

	window: EV_WINDOW

feature -- Operation

	enable is
		do
			on_press_agent := agent on_press
			widget.pointer_button_press_actions.extend (on_press_agent)
		end

	disable is
		do
			widget.pointer_button_press_actions.prune_all (on_press_agent)
		end

feature {NONE} -- Implementation

	on_app_release_agent: PROCEDURE [ANY, TUPLE [EV_WIDGET, INTEGER_32, INTEGER_32, INTEGER_32]]
	on_app_motion_agent: PROCEDURE [ANY, TUPLE [EV_WIDGET, INTEGER_32, INTEGER_32]]
	on_press_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]
	on_release_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]
	on_motion_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]
	on_leave_agent: PROCEDURE [ANY, TUPLE]

	on_leave is
		do
			deactivate
		end

	on_press (x: INTEGER; y: INTEGER; button: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER) is
			--
		do
			if button = 1 then
				if is_moving then
					deactivate
				else
					last_x := x
					last_y := y
					last_scx := screen_x
					last_scy := screen_y
					activate
				end
			end
		end

	on_app_release (w: EV_WIDGET; button: INTEGER_32; screen_x: INTEGER_32; screen_y: INTEGER_32) is
		do
			if button = 1 then
				deactivate
			end
		end

	on_release (x: INTEGER; y: INTEGER; button: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER) is
			--
		do
			if button = 1 then
				deactivate
			end
		end

	on_app_motion (w: EV_WIDGET; screen_x: INTEGER_32; screen_y: INTEGER_32) is
		local
			wx,wy,ww,wh: INTEGER
		do
			wx := window.x_position
			wy := window.y_position
			ww := window.width
			wh := window.height
			if
				screen_x < wx or screen_x > wx + ww
				or screen_y < wy or screen_y > wy + wh
			then
				deactivate
			else
				window.set_position (wx + (screen_x - last_scx), wy + (screen_y - last_scy))
				last_scx := screen_x
				last_scy := screen_y
			end
		end

	on_motion (x: INTEGER; y: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER) is
		do
			window.set_position (window.x_position + (x - last_x) + 1, window.y_position + (y - last_y) + 1)
		end

	is_moving: BOOLEAN
	last_x, last_y: INTEGER
	last_scx, last_scy: INTEGER

	activate is
		do
			is_moving := True
			widget.enable_capture

			on_motion_agent := agent on_motion
			on_release_agent := agent on_release
			on_leave_agent := agent on_leave

			widget.pointer_motion_actions.extend (on_motion_agent)
			widget.pointer_button_release_actions.extend (on_release_agent)
			widget.pointer_leave_actions.extend (on_leave_agent)
		end

	deactivate is
		do
			window.item.show

			widget.pointer_motion_actions.prune_all (on_motion_agent)
			widget.pointer_button_release_actions.prune_all (on_release_agent)
			widget.pointer_leave_actions.prune_all (on_leave_agent)

			on_motion_agent := Void
			on_release_agent := Void
			on_leave_agent := Void

			widget.disable_capture
			is_moving := False
		end

end
