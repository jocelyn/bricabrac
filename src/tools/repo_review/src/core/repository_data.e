note
	description: "Summary description for {REPOSITORY_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REPOSITORY_DATA

feature {NONE} -- Initialization

	make (a_uuid: UUID; a_repo: like repository)
		do
			uuid := a_uuid
			repository := a_repo
		end

feature -- Access

	get_logs (a_fetch: BOOLEAN)
			-- Get logs, and fetch recent if `a_fetch' is True
		deferred
		end

feature {NONE} -- Implementation

	uuid: UUID

	repository: REPOSITORY

end
