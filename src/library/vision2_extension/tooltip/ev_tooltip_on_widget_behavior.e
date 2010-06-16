indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EV_TOOLTIP_ON_WIDGET_BEHAVIOR

inherit
	EV_TOOLTIP_BEHAVIOR_I [EV_WIDGET]
		redefine
			make
		end

create
	make

feature

	make (a_target: like target)
		do
			Precursor (a_target)
			target.pointer_enter_actions.extend (agent impl_tooltip_enter)
			target.pointer_leave_actions.extend (agent impl_tooltip_leave)
		end

feature {NONE}

	target_pointer_motion_actions: EV_POINTER_MOTION_ACTION_SEQUENCE is
		do
			Result := target.pointer_motion_actions
		end

end
