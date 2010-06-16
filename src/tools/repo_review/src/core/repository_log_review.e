note
	description: "Summary description for {REPOSITORY_LOG_REVIEW}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REPOSITORY_LOG_REVIEW

create
	make

feature {NONE} -- Initialization

	make
		do
			create {ARRAYED_LIST [like reviews.item]} reviews.make (10)
		end

feature -- Access

	reviews: LIST [like new_user_review]

	user_review (a_user: STRING; a_status: detachable STRING): detachable like new_user_review
		local
			l_reviews: like reviews
		do
			l_reviews := reviews
			from
				l_reviews.start
			until
				l_reviews.after or Result /= Void
			loop
				Result := l_reviews.item
				if Result.user.is_case_insensitive_equal (a_user) then
					if a_status /= Void and then not a_status.is_case_insensitive_equal (Result.status) then
						Result := Void
					end
				else
					Result := Void
				end
				l_reviews.forth
			end
		end

	new_user_review (a_user: STRING): TUPLE [user: STRING; status: STRING; comment: detachable STRING]
		do
			Result := [a_user, "", Void]
			reviews.extend (Result)
		end

feature -- Basic operations

	approve (a_user: STRING)
		local
			l_rdata: like {REPOSITORY_LOG_REVIEW}.user_review
		do
			l_rdata := user_review (a_user, Void)
			if l_rdata = Void then
				l_rdata := new_user_review (a_user)
			end
			l_rdata.status := status_approved
		end

	refuse (a_user: STRING)
		local
			l_rdata: like {REPOSITORY_LOG_REVIEW}.user_review
		do
			l_rdata := user_review (a_user, Void)
			if l_rdata = Void then
				l_rdata := new_user_review (a_user)
			end
			l_rdata.status := status_refused
		end

	question (a_user: STRING; q: detachable STRING)
		local
			l_rdata: like {REPOSITORY_LOG_REVIEW}.user_review
		do
			l_rdata := user_review (a_user, status_question)
			if l_rdata = Void then
				l_rdata := new_user_review (a_user)
			end
			l_rdata.status := status_question
			l_rdata.comment := q
		end

	unapprove (a_user: STRING)
		do
			if attached user_review (a_user, status_approved) as l_rdata then
				check is_approved_status (l_rdata.status) end
				l_rdata.status := status_none
				reviews.prune (l_rdata)
			end
		end

	unrefuse (a_user: STRING)
		do
			if attached user_review (a_user, status_refused) as l_rdata then
				check is_refused_status (l_rdata.status) end
				l_rdata.status := status_none
				reviews.prune (l_rdata)
			end
		end

	unquestion (a_user: STRING)
		do
			if attached user_review (a_user, status_question) as l_rdata then
				check is_question_status (l_rdata.status) end
				l_rdata.status := status_none
				reviews.prune (l_rdata)
			end
		end

feature -- Status report

	stats: TUPLE [approved, refused, question: INTEGER]
		local
			n_refused: INTEGER
			n_approved: INTEGER
			n_question: INTEGER
			s: STRING
		do
			if attached reviews as l_reviews then
				from
					l_reviews.start
				until
					l_reviews.after
				loop
					s := l_reviews.item.status
					s.to_lower
					if s.is_empty then
					elseif is_approved_status (s) then
						n_approved := n_approved + 1
					elseif is_refused_status (s) then
						n_refused := n_refused + 1
					elseif is_question_status (s) then
						n_question := n_question + 1
					end
					l_reviews.forth
				end
			end
			Result := [n_approved, n_refused, n_question]
		end

	has_approval: BOOLEAN
		local
			st: like stats
		do
			st := stats
			Result := st.approved > 0
		end

	has_refusal: BOOLEAN
		local
			st: like stats
		do
			st := stats
			Result := st.refused > 0
		end

	has_question: BOOLEAN
		local
			st: like stats
		do
			st := stats
			Result := st.question > 0
		end

	is_valid_status (s: STRING): BOOLEAN
		do
			Result := True
			if s.is_empty then
			elseif s.is_case_insensitive_equal (status_approved) then
			elseif s.is_case_insensitive_equal (status_refused) then
			elseif s.is_case_insensitive_equal (status_question) then
			else
				Result := False
			end
		end

feature -- Status value

	is_none_status (s: STRING): BOOLEAN
		do
			Result := s.is_empty
		end

	is_refused_status (s: STRING): BOOLEAN
		do
			Result := s.count = 2 and then s.item (1) = 'n' and then s.item (2) = 'o'
		end

	is_approved_status (s: STRING): BOOLEAN
		do
			Result := s.count = 3 and then s.item (1) = 'y' and then s.item (2) = 'e' and then s.item (3) = 's'
		end

	is_question_status (s: STRING): BOOLEAN
		do
			Result := s.count = 8 and then s.item (1) = 'q' and then s.is_case_insensitive_equal (status_question)
		end

	status_none: STRING = ""
	status_approved: STRING = "yes"
	status_refused: STRING = "no"
	status_question: STRING = "question"

end
