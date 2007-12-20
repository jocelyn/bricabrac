indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WINDOW_RESIZING_GRIP

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

	enable_maximize (ag: like on_maximize_agent) is
			--
		require
			ag /= Void
			on_press_agent = Void
			on_release_agent = Void
		do
			on_release_agent := agent on_maximize_releaze
			on_maximize_agent := ag
			widget.pointer_button_release_actions.extend (on_release_agent)
		end

	disable_maximize is
			--
		do
			on_maximize_agent := Void
			widget.pointer_button_release_actions.prune_all (on_release_agent)
			on_release_agent := Void
		end

	enable is
		require
			on_press_agent = Void
		do
			on_press_agent := agent on_press
			widget.pointer_button_press_actions.extend (on_press_agent)
		end

	disable is
		do
			widget.pointer_button_press_actions.prune_all (on_press_agent)
			on_press_agent := Void
		end

feature -- Agent

	on_press_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]
	on_release_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]
	on_motion_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]
	on_leave_agent: PROCEDURE [ANY, TUPLE]

	on_maximize_agent: PROCEDURE [ANY, TUPLE [BOOLEAN]]

	is_maximized: BOOLEAN

feature {NONE} -- Implementation

	on_maximize_releaze (x: INTEGER; y: INTEGER; button: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER) is
		do
			if button = 1 then
				if not is_maximized then
					is_maximized := True
				else
					is_maximized := False
				end
				on_maximize_agent.call ([is_maximized])
			end
		end

	on_leave is
		do
			deactivate
		end

	on_press (x: INTEGER; y: INTEGER; button: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER) is
			--
		do
			if button = 1 then
				last_x := x
				last_y := y
				activate
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

	on_motion (x: INTEGER; y: INTEGER; x_tilt: DOUBLE; y_tilt: DOUBLE; pressure: DOUBLE; screen_x: INTEGER; screen_y: INTEGER) is
		do
			window.set_size (window.width + (x - last_x), window.height + (y - last_y))
		end

	last_x: INTEGER
	last_y: INTEGER

	activate is
		do
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
			widget.pointer_motion_actions.prune_all (on_motion_agent)
			widget.pointer_button_release_actions.prune_all (on_release_agent)
			widget.pointer_leave_actions.prune_all (on_leave_agent)

			on_motion_agent := Void
			on_release_agent := Void
			on_leave_agent := Void
			widget.disable_capture
		end

end
