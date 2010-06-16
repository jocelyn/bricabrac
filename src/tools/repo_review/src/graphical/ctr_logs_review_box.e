note
	description: "Summary description for {CTR_LOGS_REVIEW_BOX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CTR_LOGS_REVIEW_BOX

inherit
	ANY

	CTR_SHARED_RESOURCES
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialization

	make (a_tool: CTR_LOGS_TOOL)
		do
			logs_tool := a_tool
			build_interface
		end

	build_interface
		local
			b: EV_HORIZONTAL_BOX
			tb: SD_TOOL_BAR
			tbb: SD_TOOL_BAR_BUTTON
			tbtb: SD_TOOL_BAR_TOGGLE_BUTTON
			lab: EV_LABEL
		do
			create b
			widget := b
			b.set_minimum_height (32)
			b.set_border_width (2)

			create tb.make
			create tbtb.make
			tbtb.set_text ("Approve")
			tb.extend (tbtb)
			button_approve := tbtb
			tbtb.select_actions.extend (agent on_approve)

			create tbtb.make
			tbtb.set_text ("Refuse")
			tb.extend (tbtb)
			button_refuse := tbtb
			tbtb.select_actions.extend (agent on_refuse)

			create tbtb.make
			tbtb.set_text ("Comment")
			tb.extend (tbtb)
			tbtb.select_actions.extend (agent on_question)
			button_question := tbtb

			create tbb.make
			tbb.set_text ("Submit")
			tbb.select_actions.extend (agent on_submit)
			tb.extend (tbb)
			button_submit := tbb

			create lab.make_with_text ("Review:")
			b.extend (lab)
			b.disable_item_expand (lab)
			b.extend (create {EV_CELL})
			b.extend (tb)
			b.disable_item_expand (tb)

			tb.compute_minimum_size
			b.set_background_color (colors.yellow)
			b.propagate_background_color
		end

feature -- Access

	widget: EV_WIDGET

	logs_tool: CTR_LOGS_TOOL

	current_log: detachable REPOSITORY_LOG

	button_approve: SD_TOOL_BAR_TOGGLE_BUTTON
	button_refuse: SD_TOOL_BAR_TOGGLE_BUTTON
	button_question: SD_TOOL_BAR_TOGGLE_BUTTON
	button_submit: SD_TOOL_BAR_BUTTON

feature -- Event

--	review: detachable REPOSITORY_LOG_REVIEW

	on_approve
		local
			r: detachable REPOSITORY_LOG_REVIEW
		do
			if attached current_log as l_log then
				if l_log.has_review then
					r := l_log.review
				end
				if r = Void then
					create r.make
				end
				if attached l_log.parent.username as l_user then
					if button_approve.is_selected then
						r.approve (l_user)
					else
						r.unapprove (l_user)
					end
				end
				apply (l_log, r)
			end
		end

	on_refuse
		local
			r: detachable REPOSITORY_LOG_REVIEW
		do
			if attached current_log as l_log then
				if l_log.has_review then
					r := l_log.review
				end
				if r = Void then
					create r.make
				end
				if attached l_log.parent.username as l_user then
					if button_refuse.is_selected then
						r.refuse (l_user)
					else
						r.unrefuse (l_user)
					end
				end
				apply (l_log, r)
			end
		end

	on_question
		local
			r: detachable REPOSITORY_LOG_REVIEW
		do
			if attached current_log as l_log then
				if l_log.has_review then
					r := l_log.review
				end
				if r = Void then
					create r.make
				end
				if attached l_log.parent.username as l_user then
					if button_question.is_selected then
						r.question (l_user, "???")
					else
						r.unquestion (l_user)
					end
				end
				apply (l_log, r)
			end
		end

	apply (a_log: REPOSITORY_LOG; r: REPOSITORY_LOG_REVIEW)
		do
			a_log.parent.store_log_review (a_log, r)
			update_current_log (current_log)
			logs_tool.update_log (a_log)
		end

	on_submit
		do
		end

feature -- Basic operation

	update_current_log (a_log: like current_log)
		local
			l_rdata: detachable like {REPOSITORY_LOG_REVIEW}.user_review
			r: detachable REPOSITORY_LOG_REVIEW
		do
			current_log := a_log
			if a_log /= Void and then a_log.has_review then
				r := a_log.review
				if r /= Void then
					if attached a_log.parent.username as l_user then
						l_rdata := r.user_review (l_user, Void)
					end
				end
			end
			if r = Void or l_rdata = Void then
				button_approve.disable_select
				button_refuse.disable_select
				button_question.disable_select
			else
				if r.is_approved_status (l_rdata.status) then
					button_approve.enable_select
				else
					button_approve.disable_select
				end
				if r.is_refused_status (l_rdata.status) then
					button_refuse.enable_select
				else
					button_refuse.disable_select
				end
				if r.is_question_status (l_rdata.status) then
					button_question.enable_select
				else
					button_question.disable_select
				end
			end
		end

	show
		do
			widget.show
		end

	hide
		do
			widget.hide
		end

end
