indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EV_TOOLTIP_BEHAVIOR_I [G -> EV_ANY]

feature

	make (a_target: like target) is
		do
			target := a_target
		end

	set_offsets (offx, offy: INTEGER) is
		do
			offset_x := offx
			offset_y := offy
		end

	set_tooltip_function (v: like tooltip_function) is
		do
			tooltip_function := v
		end

	tooltip_function: FUNCTION [ANY, TUPLE [like target], STRING_GENERAL]


feature {NONE} -- Deferred access

	target: G

	target_pointer_motion_actions: EV_POINTER_MOTION_ACTION_SEQUENCE is
		deferred
--			Result := target.pointer_motion_actions
		end

feature {NONE} -- Impl

	offset_x: INTEGER

	offset_y: INTEGER

	impl_tooltip_enter is
		do
			if tooltip_function /= Void then
				agent_impl_tooltip_motion := agent impl_tooltip_motion
				target_pointer_motion_actions.extend (agent_impl_tooltip_motion)
			end
		end

	impl_tooltip_leave is
		do
			if agent_impl_tooltip_motion /= Void then
				if imp_tooltip_delayed_action /= Void then
					imp_tooltip_delayed_action.cancel_request
					imp_tooltip_delayed_action := Void
				end
				target_pointer_motion_actions.prune_all (agent_impl_tooltip_motion)
				agent_impl_tooltip_motion := Void
			end
		end

	agent_impl_tooltip_motion: PROCEDURE [ANY, TUPLE [INTEGER, INTEGER, DOUBLE, DOUBLE, DOUBLE, INTEGER, INTEGER]]

	impl_tooltip_motion (ax, ay: INTEGER; ax_tilt, ay_tilt, apressure: DOUBLE; ascreen_x, ascreen_y: INTEGER) is
		do
			if imp_tooltip_delayed_action = Void then
				create imp_tooltip_delayed_action.make (agent imp_tooltip_show, 1000)
			end
			imp_tooltip_delayed_action.request_call ([ascreen_x, ascreen_y])
		end

	imp_tooltip_show (ascreen_x, ascreen_y: INTEGER) is
		require
			tooltip_function /= Void
		local
			ttw: EV_POPUP_WINDOW
			lab: EV_LABEL
			delayed_close: EV_DELAYED_ACTION_ARGS [TUPLE]
			bborder,binner: EV_VERTICAL_BOX
			s: STRING_GENERAL
			lpointer_motion_actions: EV_POINTER_MOTION_ACTION_SEQUENCE
		do
			s := tooltip_function.item ([target])
			if s /= Void then
				create ttw
				create bborder
				bborder.set_border_width (1)
				create binner
				binner.set_border_width (2)
				create lab

				lab.set_text (s)
				binner.extend (lab)
				bborder.extend (binner)
				ttw.extend (bborder)
				create delayed_close.make (agent ttw.destroy, 2000)
				ttw.set_data (delayed_close)
				lpointer_motion_actions := target_pointer_motion_actions
				lpointer_motion_actions.extend_kamikaze (agent lpointer_motion_actions.wrapper (?, ?, ?, ?, ?, ?, ?, agent delayed_close.call(Void)))

				binner.set_background_color ((create {EV_STOCK_COLORS}).White)
				binner.propagate_background_color
				bborder.set_background_color ((create {EV_STOCK_COLORS}).Black)
				ttw.set_position (ascreen_x + offset_x , ascreen_y + offset_y)
				ttw.show

				delayed_close.request_call (Void)
			end
		end

	imp_tooltip_delayed_action: EV_DELAYED_ACTION_ARGS [TUPLE [INTEGER, INTEGER]]

end
