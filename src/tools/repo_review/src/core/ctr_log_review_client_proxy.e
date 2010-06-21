note
	description: "Summary description for {CTR_LOG_REVIEW_CLIENT_PROXY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CTR_LOG_REVIEW_CLIENT_PROXY

create
	make

feature {NONE} -- Initialization

	make (a_repo: like repository)
		do
			repository := a_repo
		end

feature -- Basic operation

	reset
		do
			last_error := 0
		end

	login
		do
			last_error := err_invalid_account
		end

	submit (a_log: REPOSITORY_LOG; a_review: REPOSITORY_LOG_REVIEW)
		local
			e: detachable REPOSITORY_LOG_REVIEW_ENTRY
			r: STRING
			l_user_name: like username
		do
			l_user_name := username

			create r.make_empty
			r.append_string (a_log.id)
			r.append_character ('[')
			r.append_string (l_user_name)
			r.append_character (']')
			if
				attached a_review.user_local_entries (l_user_name, Void) as l_entries
			then
				create r.make (25)
				across
					l_entries as c
				loop
					e := c.item
					r.append_character ('(')
					r.append_string (e.status)
					if attached e.comment as l_comment then
						r.append_character (':')
						r.append_string (l_comment)
					end
					r.append_character (')')
					r.append_character (' ')
				end

				login
				if not last_error_occurred then
					-- DO SUBMISSION
				end
				if not last_error_occurred then
					across
						l_entries as c
					loop
						e := c.item
						e.set_is_remote (True)
					end
				end
			end
			print (r + "%N")

			last_error := err_connection_trouble
		end

feature -- Status report

	last_error: NATURAL_8

	last_error_occurred: BOOLEAN
		do
			Result := last_error > 0
		end

	last_error_message: STRING
		do
			Result := error_message (last_error)
		end

	error_message (a_error: like last_error): STRING
		do
			inspect a_error
			when err_invalid_account then
				Result := "Invalid account for " + username
			when err_connection_trouble then
				Result := "Trouble during connection"
			else
				Result := "Error [" + a_error.out + "] occurred"
			end
		end

feature -- Access

	repository: REPOSITORY

	username: STRING
		do
			if attached repository.username as l_username then
				Result := l_username
			else
				Result := "anonymous"
			end
		end

feature -- Constants

	err_invalid_account: like last_error = 1
	err_connection_trouble: like last_error = 2

end
