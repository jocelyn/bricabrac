note
	description: "Summary description for {REPOSITORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REPOSITORY

feature {NONE} -- Initialization

	make
		do
			create uuid
		end

feature -- Access

	uuid: UUID

	has_uuid: BOOLEAN
		do
			Result := uuid /~ create {UUID}
		end

	location: STRING
		deferred
		end

	review_enabled: BOOLEAN

	review_variables: detachable HASH_TABLE [STRING, STRING]

	review_username: detachable STRING

	review_password: detachable STRING

	review_url: detachable STRING

	review_name: detachable STRING

--	add_token (a_pattern: STRING; a_replacement: STRING)
--		local
--			l_tokens: like tokens
--		do
--			l_tokens := tokens
--			if l_tokens = Void then
--				create {LINKED_LIST [like tokens.item]} l_tokens.make
--				tokens := l_tokens
--			end
--			l_tokens.extend ([a_pattern, a_replacement])
--		end

--	tokens: detachable LIST [TUPLE [pat: STRING; rep: STRING]]

	issue_url_pattern: detachable STRING

	issue_url (s: STRING): detachable STRING
		do
			if attached issue_url_pattern as p then
				create Result.make_from_string (p)
				Result.replace_substring_all ("$$", s)
			end
		end

feature -- Element change

	set_location (v: like location)
		require
			v_attached: v /= Void
		deferred
		ensure
			location_set: v ~ location
		end

	set_uuid (u: like uuid)
		do
			uuid := u
		end

	add_review_variable (v: STRING; k: STRING)
		require
			k_attached: k /= Void
			k_lowered: k.same_string (k.as_lower)
		local
			l_vars: like review_variables
		do
			l_vars := review_variables
			if l_vars = Void then
				create l_vars.make (6)
				review_variables := l_vars
			end
			l_vars.force (v, k)
		end

	set_review_variables (v: like review_variables)
		require
			v_attached: v /= Void
		do
			review_variables := v
		end

	set_review_enabled (v: like review_enabled)
		do
			review_enabled := v
		ensure
			commit_then_review_enabled_set: review_enabled = v
		end

	set_review_url (v: like review_url)
		require
			v_attached: v /= Void
		do
			review_url := v
			add_review_variable(v, "url")
		ensure
			review_url_set: v ~ review_url
		end

	set_review_name (v: like review_name)
		require
			v_attached: v /= Void
		do
			review_name := v
			add_review_variable (v, "name")
		ensure
			review_name_set: v ~ review_name
		end

	set_review_username (v: like review_username)
		require
			v_attached: v /= Void
		do
			review_username := v
			add_review_variable (v, "username")
		ensure
			username_set: v ~ review_username
		end

	set_review_password (v: like review_password)
		require
			v_attached: v /= Void
		do
			review_password := v
			add_review_variable (v, "password")
		ensure
			password_set: v ~ review_password
		end

	set_issue_url_pattern (v: like issue_url_pattern)
		do
			issue_url_pattern := v
		ensure
			issue_url_pattern_set: v ~ issue_url_pattern
		end

end
