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

	username: detachable STRING

	password: detachable STRING

	review_enabled: BOOLEAN

feature -- Element change

	set_review_enabled (v: like review_enabled)
		do
			review_enabled := v
		ensure
			commit_then_review_enabled_set: review_enabled = v
		end

	set_uuid (u: like uuid)
		do
			uuid := u
		end

	set_username (v: like username)
		require
			v_attached: v /= Void
		do
			username := v
		ensure
			username_set: v ~ username
		end

	set_password (v: like password)
		require
			v_attached: v /= Void
		do
			password := v
		ensure
			password_set: v ~ password
		end

end
